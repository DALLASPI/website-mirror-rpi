#!/usr/bin/env bash
# Description: This script automates the process of mirroring a website and hosting it in a Docker container on a Raspberry Pi.
set -e # Exit on any command failure
trap cleanup EXIT
cleanup() {
 # Add any cleanup code if needed
 echo "Cleanup completed."
}
# Get the home directory of the current user
USER_HOME=$(eval echo ~"$USER")
# Constants with environment variables and default fallbacks
DEFAULT_SAVE_PATH="${MIRROR_SAVE_PATH:-$USER_HOME/mirroredsite}"
DEFAULT_PORT=80
# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
 echo "This script must be run as root or with sudo privileges."
 exit 1
fi
# Check if Docker and wget are installed and Docker is running
for cmd in docker wget; do
 if ! command -v "$cmd" &> /dev/null; then
 echo "Error: $cmd is not installed."
 exit 1
 fi
done
if ! systemctl is-active --quiet docker; then
 echo "Error: Docker is not running. Please ensure Docker is set up correctly."
 exit 1
fi
# Usage message
usage() {
 echo "Usage: $0 -u WEBSITE_URL [-s SAVE_PATH] [-p DOCKER_PORT]"
 echo " -u Website URL to mirror."
 echo " -s Path to save the mirrored website. Default: $DEFAULT_SAVE_PATH."
 echo " -p Port to run the Docker container. Default: $DEFAULT_PORT."
 exit 1
}
# Check if port is in use using 'ss' command
is_port_in_use() {
 local port="$1"
 ss -tuln | grep -q ":$port "
}
# Parse command-line flags
while getopts ":u:s:p:" opt; do
 case $opt in
 u) website_url="$OPTARG"
 ;;
 s) save_path="$OPTARG"
 ;;
 p) docker_port="$OPTARG"
 ;;
 \?) echo "Invalid option -$OPTARG" >&2
 usage
 ;;
 :) echo "Option -$OPTARG requires an argument." >&2
 usage
 ;;
 esac
done
# Check if URL is provided
if [ -z "$website_url" ]; then
 echo "Error: Website URL not provided."
 usage
fi
# Set default values if not provided
save_path=${save_path:-"$DEFAULT_SAVE_PATH/$(basename "$website_url")"}
docker_port=${docker_port:-$DEFAULT_PORT}
container_name="$(basename "$website_url")-container"
image_name="${container_name}-image"
# Check if port is already in use
if is_port_in_use "$docker_port"; then
 echo "Error: Port $docker_port is already in use. Please choose a different port."
 exit 1
fi
# Mirror the website using wget
echo "Mirroring the website: $website_url..."
mkdir -p "$save_path"
if ! wget --mirror --convert-links --adjust-extension --page-requisites --no-parent -P "$save_path" "$website_url"; then
 echo "Error: Failed to mirror the website."
 exit 1
fi
# Create Dockerfile
echo "Creating Dockerfile..."
cat <<EOL > "$save_path/Dockerfile"
FROM nginx:alpine
COPY ./ /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOL
# Navigate to the directory and build the Docker image
echo "Building the Docker image..."
cd "$save_path"
if ! docker build -t "$image_name" .; then
 echo "Error: Failed to build the Docker image."
 exit 1
fi
# Check if a container with the same name is already running
if docker ps -qf name="$container_name" | grep -q .; then
 echo "Stopping and removing existing container..."
 docker stop "$container_name"
 docker rm "$container_name"
fi
# Run the Docker container
echo "Running the Docker container on port $docker_port..."
if ! docker run -d -p "$docker_port:80" --name "$container_name" "$image_name"; then
 echo "Error: Failed to run the Docker container."
 exit 1
fi
# Display access information
ip_address=$(hostname -I | awk '{print $1}')
echo "Done! You can now access the mirrored website by navigating to http://$ip_address:$docker_port"
