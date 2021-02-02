# backend-deploy-action

This action must be used when you want to deploy the backend (or update if the backend is running already). It will fail when launched from any branches except “awsstaging” and “awsproduction”.

## Example workflows file
```yaml
name: "backend_deploy"
on:
  workflow_dispatch:
    branches:
    - awsstaging
    - awsproduction
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - uses: Emblematic-Group/backend-deploy-action@main
      env:
        BACKEND_FOLDER: 'backend'
        SSH_KEY_PEM: ${{ secrets.BACKEND_SSH_KEY_PEM }}
        SSH_HOST: ${{ secrets.SSH_HOST }}
```

## Example break-down
This actions can be triggered only from the Action tab since it is a workflow_dispatch.

The only branch allowed to dispatch this action is awsstaging and awsproduction.
### Steps:
- actions/checkout@v1 is used to allow the action to pull the repo
- Emblematic-Group/aws-update-lambda-functions-action@main runs AWS CLI/SAM commands to update the lambda functions

### Env variables
- BACKEND_FOLDER, which is the path to the folder in the repo where you can find the ecosystem file
- SSH_KEY_PEM, used to recreate the ssh key to access the remote host
- SSH_HOST, refering to the name of the remote host (ubuntu@...)


### Second step summary
- Checks whether the env variables are initialized
- Checks whether the needed folders for pm2 exist and creates them when they don’t
- Performs pm2 deployment for the backend. There could be two situations:
    1. Deploy a new instance if there is none for that environment
    2. Update the already existing instance for that environment
