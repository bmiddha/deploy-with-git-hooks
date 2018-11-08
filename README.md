# deploy-with-git-hooks

This script sets up a bare git repository with the post-receive hook to auto checkout the project into the deployment/production directory.

## Usage
```
Usage: test/dep.sh --git <example.git> --deploy <deploy_here> {--user | --host | --parent-directory | --branch}

  Required: 
      -g, --git               Bare Git Repository
      -d, --deploy            Deploy Location/Directory
  Optional: 
      -u, --user              SSH User (Default is current user)
      -a, --host              Host IP/Domain (Default is public IP)
      -p, --parent-directory  Specify Parent Directory (Default is currnet directory)
      -b, --branch            Specify Deploy Branch (Default is master)
      -h, --help              Displays Help Information
```
