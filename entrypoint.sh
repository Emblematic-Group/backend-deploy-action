#!/bin/bash

echo "JOB STARTED"

set -e

echo "Check env variables STARTED"

if [[ ! -z "$BACKEND_FOLDER" ]]; then
    cd $BACKEND_FOLDER
fi

if [[ -z "$SSH_KEY_PEM" ]]; then
    echo Missing ssh key
    exit 1
fi

if [[ -z "$SSH_HOST" ]]; then
    echo Missing ssh host
    exit 1
fi

BRANCH_NAME="$(echo ${GITHUB_REF#refs/heads/})"

if [[ "$BRANCH_NAME" != "awsstaging" && "$BRANCH_NAME" != "awsproduction" ]]; then
    echo "Wrong branch. Only allowed for awsstaging and awsproduction"
    exit 1
fi

echo "STARTING PM2 ACTION FOR BRANCH ${BRANCH_NAME}"

mkdir -p ~/ssh-keys
touch ~/ssh-keys/EmblematicReachServerSSHKey.pem
echo "$SSH_KEY_PEM" > ~/ssh-keys/EmblematicReachServerSSHKey.pem
chmod 400 ~/ssh-keys/EmblematicReachServerSSHKey.pem

echo "Check the existence of branch folders on remote pc"

CHECK_LENGHT=$(ssh -o StrictHostKeyChecking=no -i ~/ssh-keys/EmblematicReachServerSSHKey.pem $SSH_HOST "[ -d ~/emblematic-github/${BRANCH_NAME} ] && echo true")
if [[ -z "$CHECK_LENGHT" ]]; then
    echo "Folders don't exist for the branch ${BRANCH_NAME}. Busy creting them."
	
    if [[ "$BRANCH_NAME" == "awsstaging" ]]; then
        pm2 deploy ecosystem.staging.config.js staging setup
    fi

    if [[ "$BRANCH_NAME" == "awsproduction" ]]; then
        pm2 deploy ecosystem.production.config.js production setup
    fi
fi


echo "Deploy/Update the backend with pm2"

if [[ "$BRANCH_NAME" == "awsstaging" ]]; then
    pm2 deploy ecosystem.staging.config.js staging update --force
fi

if [[ "$BRANCH_NAME" == "awsproduction" ]]; then
    pm2 deploy ecosystem.production.config.js production update --force
fi

echo "Deployment is complete!"