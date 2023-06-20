[![rstudio image](https://github.com/stuart-lab/aws/actions/workflows/docker-image.yml/badge.svg)](https://github.com/stuart-lab/aws/actions/workflows/docker-image.yml)

# Setting up AWS EC2 instance

1. Log into AWS console
2. EC2 > launch instance
3. Choose a name
4. Select Ubuntu 22.04 operating system
5. Choose instance type that is the minimum required for the project
6. Select key pair, or create one
7. Allow SSH traffic from your computer IP address only
8. Select the amount of EBS storage required
9. Launch instance
10. Got to instance details > security > security groups > inbound > add rule
11. Add the following custom TCP rules: port 8787 (rstudio), port 8888 (jupyterlab)
12. Copy the IP address
13. Log in via ssh: `ssh -i <key> ubuntu@<ip>`
14. Run an OS update:
    ```bash
    sudo apt update
    sudo apt upgrade -y
    sudo apt dist-upgrade
    sudo reboot
    ```
16. Log back in once rebooted and clone this repository: `git clone https://github.com/stuart-lab/aws.git`
17. Run startup script to install dependencies: `sh aws/startup.sh`
18. Logout

# Installing AWS CLI

Download and install:

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Configure:

```
aws configure
```

To create AWS access keys, log into the AWS console and go to:

Security credentials -> Access keys -> Create new access key

Note the key ID and secret access key.

# Storing logs

A*STAR policy requires that system logs are stored for a minimum of 1 year for EC2 instances. To ensure logs are stored,
we copy from `/var/log/` to an S3 bucket using a shell script. This shell script can be run automatically each time you
log out of the server by including it in the `~/.bash_logout` file.

First, make sure the aws cli is authenticated so that you can write to the S3 bucket (above). Next, add this code to
`~/.bash_logout` to ensure compliance with A*STAR policies:

```bash
# copy logs to S3 bucket for storage
aws s3 cp /var/log/ s3://stuartlab-logs/$(date +'%d_%m_%Y')/$RANDOM --recursive --exclude "*" --include "*log"
```

# Starting RStudio Server

1. Run rstudio docker image:

```
docker run --name rstudio --rm -e PASSWORD=password -d -p 8787:8787 timoast/rstudio
```

2. Open `<ip>:8889`, enter username `rstudio` and passwork `password`

# Running R interactively

```
docker run -ti --rm timoast/rstudio R
```

# Other tips

The instance type can be changed easily via the AWS console by stopping the instance and then selecting
Actions > Instance settings > Change instance type. You should try to use the minimum instance size
that is required for the computations that are being run. Scale the instance type according to need. 

Useful links:  
https://ec2-tutorials.readthedocs.io/en/latest/index.html  
https://davetang.org/muse/2022/12/07/running-rstudio-server-on-amazon-ec2/  
https://davetang.org/muse/2019/12/23/uploading-to-amazon-s3/  
https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/rstudio_devel.Dockerfile  
https://rocker-project.org/images/versioned/rstudio.html  

