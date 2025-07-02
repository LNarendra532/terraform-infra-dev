#!/bin/bash

component=$1
dnf install ansible -y
ansible-pull -U https://github.com/LNarendra532/ansible-robo-roles-tf.git  -e component=$1 env=$2 main.yaml