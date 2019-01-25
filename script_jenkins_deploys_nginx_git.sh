#!/bin/bash

var_destination_server_user='jenkins'
var_destination_server_host='172.18.0.3'
var_destination_server_dir_deploy='/data/deploy'
var_destination_server_dir_application='/data/production/html'

var_jenkins_project_workspace=$WORKSPACE
var_jenkins_home=$JENKINS_HOME

echo "Build date: $(date)" 
echo "Project full workspace dir: $WORKSPACE"
echo "TAG used: $TAGS"

#check if dir exists. Case exists force build failure e stop execution
if [ -z "$var_destination_server_user@$var_destination_server_host:$var_destination_server_dir_deploy/$TAGS" ]; then
    echo "The tag not exists in another deploy. The tag folder will not created"
    ssh $var_destination_server_user@$var_destination_server_host mkdir $var_destination_server_dir_deploy/$TAGS
fi

echo "Copy files and folder to remote server $var_destination_server_host"
scp -r  $WORKSPACE/* $var_destination_server_user@$var_destination_server_host:$var_destination_server_dir_deploy/$TAGS
echo "Sync files in remote server"
ssh $var_destination_server_user@$var_destination_server_host rsync -avz $var_destination_server_dir_deploy/$TAGS/* $var_destination_server_dir_application --delete
echo "Restarting service nginx"
ssh $var_destination_server_user@$var_destination_server_host sudo service nginx status
