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
10. Go to instance details > security > security groups > inbound > add rule
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
16. Log back in once rebooted and clone this repository: `git clone https://github.com/stuart-lab/aws-setup.git`
17. Run startup script to install dependencies: `sh aws-setup/startup.sh`
18. Logout

# Installing AWS CLI

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

# Installing mamba

https://github.com/conda-forge/miniforge#mambaforge

```
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
bash Mambaforge-$(uname)-$(uname -m).sh
```

# Installing Nvidia drivers

If using an instance with a GPU, you will need to install the Nvidia drivers. Follow the instructions [here](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#)
or use the following for a `g4dn` instance:

```
sudo apt install nvidia-cuda-toolkit
sudo apt install nvidia-driver-510
sudo reboot
nvidia-smi
nvcc -V
```

# Installing jupyterlab

Jupyterlab should be installed in the base mamba environment, all other packages will be installed in separate environments.

From the base mamba environment, run:

```
mamba install -c conda-forge jupyterlab nodejs jupytext ipywidgets
```

## Creating an environment

To create a new environment:

```
mamba create -n env
mamba activate env

# to link to the jupyterlab kernelspec
mamba install -c anaconda ipykernel
python -m ipykernel install --user --name env --display-name "Python (env)"
```

Note that you need to activate the environment before linking the kernel.

## Installing pytorch

```
# create a new mamba environment
mamba create -n torch
mamba activate torch
```

For GPU support, the CUDA toolkit needs to be installed and available. Check whether it's installed by running:

```
nvcc --version
```

Choose one of the following lines depending on compute environment:

```
# install pytorch with CPU support
mamba install -c pytorch pytorch torchvision torchaudio cpuonly
```

```
# install pytorch with GPU support for CUDA 11.7
mamba install -c pytorch -c nvidia pytorch torchvision torchaudio pytorch-cuda=11.7
```

```
# install pytorch with GPU support for CUDA 11.6
mamba install -c pytorch -c nvidia pytorch torchvision torchaudio pytorch-cuda=11.6
```

Install ipywidgets and link the kernel:

```
# install ipywidgets within the environment
mamba install -c conda-forge ipywidgets

# link kernel to jupyter
mamba install -c anaconda ipykernel
python -m ipykernel install --user --name torch --display-name "Python (torch)"
```

# Running jupyterlab

On the AWS machine run:

```
jupyter lab --no-browser --port=8889
```

On your local machine, set up SSH port forwarding:

```
ssh -f <user>@<remote> -L 8889:localhost:8889 -N
```

# Starting RStudio Server

1. Run rstudio docker image:

```
mkdir rstudio # create directory for rstudio docker filesystem
docker run --name rstudio -v /home/ubuntu/rstudio:/home/rstudio --rm -e PASSWORD=password -d -p 8787:8787 timoast/rstudio
```

2. Open `<ip>:8889`, enter username `rstudio` and passwork `password`

# Running R interactively

```
docker run -ti --rm timoast/rstudio R
```

# Building Signac website

The required data is stored at `s3://stuartlab/vignette_data/`:

```
git clone https://github.com/stuart-lab/signac.git
cd signac
mkdir vignette_data
cd vignette_data

# copy vignette data from s3
# this takes a while
aws s3 sync s3://stuartlab/vignette_data/ .
cd ..

# checkout the branch needed
git checkout develop
git pull

# we need to build certain vignettes first so the object is present and updated
Rscript -e "pkgdown::build_article('monocle')"
Rscript -e "pkgdown::build_article('pbmc_multiomic')"
Rscript -e "pkgdown::build_article('mouse_brain_vignette')"

# build the whole site
Rscript -e "pkgdown::build_site()"
```

You might need to set the github PAT, follow instructions from usethis.

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

