# Clone the Debian 12 repository
git clone https://github.com/ParaNoob123/Debain-12
# Go's To Debain-12 Repo
cd Debain-12

# Build the Docker image
docker build -t debian-vm .

# Run the container
docker run --privileged -p 6080:6080 -p 2221:2221 \
    -v $PWD/vmdata:/data debian-vm
