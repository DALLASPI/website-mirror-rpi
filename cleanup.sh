#!/usr/bin/env bash

# Constants
DEFAULT_PORT=80

# Usage message
usage() {
    echo "Usage: $0 -u WEBSITE_URL [-p DOCKER_PORT]"
    exit 1
}

# Parse command-line flags
while getopts ":u:p:" opt; do
  case $opt in
    u) website_url="$OPTARG"
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
docker_port=${docker_port:-$DEFAULT_PORT}
container_name="$(basename "$website_url")-container"
image_name="${container_name}-image"

# Stop and remove the Docker container
if docker ps -a | grep -q "$container_name"; then
    echo "Stopping and removing the Docker container: $container_name..."
    docker stop "$container_name"
    docker rm "$container_name"
else
    echo "Docker container $container_name not found."
fi

# Optionally, remove the Docker image
read -p "Do you want to remove the Docker image $image_name as well? (y/N): " choice
case "$choice" in
  y|Y ) 
    if docker image inspect "$image_name" &> /dev/null; then
        docker rmi "$image_name"
        echo "Docker image $image_name removed."
    else
        echo "Docker image $image_name not found."
    fi
  ;;
  * ) echo "Exiting without removing the Docker image.";;
esac

echo "Cleanup completed."
