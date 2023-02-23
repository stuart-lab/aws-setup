[![rstudio image](https://github.com/stuart-lab/aws/actions/workflows/docker-image.yml/badge.svg)](https://github.com/stuart-lab/aws/actions/workflows/docker-image.yml)

# Setting up AWS EC2 instance

1. Log into AWS console
2. EC2 > launch instance
3. Choose a name
4. Select Ubuntu 22.04 operating system
5. Choose instance type that is the minimum required for the project
6. Select key pair, or create one
7. Allow SSH traffic from anywhere
8. Select the amount of EBS storage required
9. Launch instance
10. Got to instance details > security > security groups > inbound > add rule
11. Add rule for custom TCP, 8000-9000, source anywhere. HTTP, 80, anywhere. HTTPS, 443, anywhere
12. Copy the IP address
13. Log in via ssh: `ssh -i <key> ubuntu@<ip>`
14. Clone this repository: `git clone git@github.com:stuart-lab/aws.git`
15. Run startup script to install dependencies: `startup.sh`
16. Logout

# Starting RStudio Server

1. Run rstudio docker image:

```
docker run --name rstudio --rm -e PASSWORD=password -d -p 8889:8787 timoast/rstudio
```

2. Open `<ip>:8889`, enter username `ubuntu` and passwork `password`

# Starting Jupyterlab

1. 

Useful links:  
https://ec2-tutorials.readthedocs.io/en/latest/index.html  
https://davetang.org/muse/2022/12/07/running-rstudio-server-on-amazon-ec2/  
https://davetang.org/muse/2019/12/23/uploading-to-amazon-s3/  
https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/rstudio_devel.Dockerfile  
https://rocker-project.org/images/versioned/rstudio.html  

