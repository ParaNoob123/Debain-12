# Clone the Debian 12 repository
git clone https://github.com/ParaNoob123/Debain-12
cd debian12

# Build the Docker image
docker build -t debian-vm .

# Run the container
docker run --privileged -p 6080:6080 -p 2221:2222 -v $PWD/vmdata:/data debian-vm
