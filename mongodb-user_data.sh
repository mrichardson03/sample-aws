#!/bin/bash

# https://www.digitalocean.com/community/tutorials/how-to-install-mongodb-on-ubuntu-16-04
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt update
sudo apt install -y mongodb-org
sudo mongo --eval "db.createUser({user: 'testuser', pwd: 'testpass', roles: [{role: 'readWrite', db: 'test'}]})"
sudo systemctl start mongod
sudo systemctl enable mongod
