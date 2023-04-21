package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestSampleAws(t *testing.T) {
	t.Parallel()

	awsRegion := "us-east-1"

	uniqueId := random.UniqueId()
	envName := fmt.Sprintf("terratest-%s", strings.ToLower(uniqueId))

	infrastructureDirectory := "../infrastructure"
	kubernetesDirectory := "../kubernetes"

	defer test_structure.RunTestStage(t, "teardown_infrastructure", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, infrastructureDirectory)
		keyPair := test_structure.LoadEc2KeyPair(t, infrastructureDirectory)

		// Destroy infrastructure resources and delete key pair
		terraform.Destroy(t, terraformOptions)
		aws.DeleteEC2KeyPair(t, keyPair)
	})

	test_structure.RunTestStage(t, "deploy_infrastructure", func() {
		keyPair := aws.CreateAndImportEC2KeyPair(t, awsRegion, envName)

		// Construct the Terraform options with default retryable errors.
		infrastructureOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: infrastructureDirectory,

			Vars: map[string]interface{}{
				"env_name": envName,
				"key_name": envName,
			},
		})

		test_structure.SaveTerraformOptions(t, infrastructureDirectory, infrastructureOptions)
		test_structure.SaveEc2KeyPair(t, infrastructureDirectory, keyPair)

		terraform.InitAndApply(t, infrastructureOptions)
	})

	test_structure.RunTestStage(t, "deploy_k8s", func() {
		clusterName := fmt.Sprintf("%s-eks-cluster", envName)

		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: kubernetesDirectory,

			Vars: map[string]interface{}{
				"cluster_name": clusterName,
			},
		})

		test_structure.SaveTerraformOptions(t, kubernetesDirectory, terraformOptions)

		terraform.InitAndApply(t, terraformOptions)
	})

	defer test_structure.RunTestStage(t, "teardown_k8s", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, kubernetesDirectory)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		infrastructureOptions := test_structure.LoadTerraformOptions(t, infrastructureDirectory)
		keyPair := test_structure.LoadEc2KeyPair(t, infrastructureDirectory)

		mongoInstance := terraform.Output(t, infrastructureOptions, "mongodb_instance")

		testSshToInstance(t, infrastructureOptions, keyPair, mongoInstance)
	})
}

func testSshToInstance(t *testing.T, terraformOptions *terraform.Options, keyPair *aws.Ec2Keypair, hostname string) {
	publicHost := ssh.Host{
		Hostname:    hostname,
		SshKeyPair:  keyPair.KeyPair,
		SshUserName: "ubuntu",
	}

	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("SSH to public host %s", hostname)

	// Run a simple echo command on the server.
	expectedText := "Hello, world"
	command := fmt.Sprintf("echo -n '%s'", expectedText)

	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		actualText, err := ssh.CheckSshCommandE(t, publicHost, command)

		if err != nil {
			return "", nil
		}

		if strings.TrimSpace(actualText) != expectedText {
			return "", fmt.Errorf("Expected SSH command to return '%s' but got '%s'", expectedText, actualText)
		}

		return "", nil
	})
}
