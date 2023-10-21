# website-mirror-rpi
Scripts to automate the process of mirroring a website and hosting it on a Raspberry Pi using Docker. Includes both the main mirroring script and a cleanup script.
Certainly! Here's a revised `README.md` for your repository:

---

# Website Mirror for Raspberry Pi

Scripts to automate the process of mirroring a website and hosting it on a Raspberry Pi using Docker. This repository contains both the main mirroring script (`script.sh`) and a cleanup script (`cleanup.sh`).

## Prerequisites

- A Raspberry Pi with a compatible OS (e.g., Raspbian).
- Docker installed and running on the Raspberry Pi.
- `httrack` tool installed.
- Git (for cloning the repository).

## Installation

1. Clone this repository to your Raspberry Pi:
   ```bash
   git clone https://github.com/DALLASPI/website-mirror-rpi.git
   cd website-mirror-rpi
   ```

2. Make the scripts executable:
   ```bash
   chmod +x script.sh cleanup.sh
   ```

## Usage

### Mirroring a Website

Run the main script with the following command:
```bash
./script.sh -u WEBSITE_URL [-s SAVE_PATH] [-p DOCKER_PORT]
```

- `-u`: (Required) The URL of the website you want to mirror.
- `-s`: (Optional) Path to save the mirrored website. Default is in the home directory under `mirroredsite`.
- `-p`: (Optional) Port to run the Docker container. Default is `80`.

### Cleanup

Run the cleanup script to remove the mirrored site and Docker container:
```bash
./cleanup.sh -u WEBSITE_URL [-p DOCKER_PORT]
```

## Contributing

If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is open-source and available under the [MIT License](LICENSE).

---

This structure should now correctly reference both scripts and provide clear instructions for GitHub users. You can update your `README.md` on GitHub with this content.
