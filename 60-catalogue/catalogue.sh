#!/bin/bash

component=$1
dnf install ansible -y
ansible-pull -U https://github.com/LNarendra532/ansible_robo_roles.git  -e component=$1 main.yaml