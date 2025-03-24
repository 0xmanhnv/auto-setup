# Auto Setup Scripts

Scripts for automatically installing and configuring development environment on Linux operating systems.

## Directory Structure

```
.
├── common.sh        # Script for installing basic development tools
└── README.md        # Documentation
```

## Features

### common.sh
- Install and configure ZSH with Oh-My-Zsh
- Install and configure useful Oh-My-Zsh plugins:
  - zsh-syntax-highlighting
  - zsh-autosuggestions
  - zsh-completions
  - zsh-history-substring-search
- Install programming languages:
  - Go
  - Rust
  - Python
  - Node.js
- Install package managers:
  - Yarn
  - pip
- Install essential tools:
  - Git
  - curl
  - wget
- Automatically configure PATH in `.zshrc`
- Set timezone (default: Asia/Ho_Chi_Minh)
- Support for multiple Linux distributions
- Works both in standard environments and Docker containers

## System Requirements

- Supported Linux operating systems:
  - Ubuntu
  - Debian
  - Parrot OS
  - Kali Linux
  - Linux Mint
  - Elementary OS
- Internet connection
- Regular user with sudo privileges (in standard environment)
- Or root access (in Docker)

## Usage

### Standard Environment

1. Download the script:
   ```bash
   curl -O https://raw.githubusercontent.com/yourusername/auto-setup/main/common.sh
   ```
   or
   ```bash
   wget https://raw.githubusercontent.com/yourusername/auto-setup/main/common.sh
   ```

2. Make the script executable:
   ```bash
   chmod +x common.sh
   ```

3. Run the script:
   ```bash
   ./common.sh
   ```

### Docker Environment

1. Inside your Dockerfile:
   ```dockerfile
   FROM ubuntu:latest
   
   COPY common.sh /root/common.sh
   RUN chmod +x /root/common.sh && /root/common.sh
   ```

2. Or in a running container:
   ```bash
   docker cp common.sh container_name:/root/
   docker exec container_name chmod +x /root/common.sh
   docker exec container_name /root/common.sh
   ```

## What Happens During Installation

The script will:
1. Detect your operating system and package manager
2. Detect whether you're running in a Docker environment
3. Update package repositories
4. Set your timezone
5. Install essential tools (Git, curl, wget)
6. Install ZSH and make it your default shell
7. Install Oh-My-Zsh with useful plugins
8. Install Go, Rust, Python, and Node.js
9. Install Yarn and pip package managers
10. Configure PATH environment variables in `.zshrc`

## Important Notes

- In standard environments: The script should be run as a regular user (not as root)
- In Docker containers: The script will automatically run appropriately with root
- The script will automatically detect if sudo is available and use it when needed
- The script checks if components are already installed before installing them
- Your existing `.zshrc` file will be backed up if changes are needed
- The script will show detailed progress and success/error messages

## Command Line Options

- `-v, --version`: Show script version
- `-h, --help`: Show help message

## Troubleshooting

- If you encounter duplicate PATH entries in your `.zshrc` file:
  - The script now includes automatic cleanup of duplicate entries
  - You can manually trigger the cleanup by running the script again
  - Or manually edit your `.zshrc` file to remove duplicate entries
  - A backup of your original `.zshrc` is created before any changes

- If you encounter network connection issues during installation:
  - The script will try to use alternative methods for installing components
  - For pip installation issues, you can manually install it later using:
    ```bash
    sudo apt update && sudo apt install python3-pip  # For Debian/Ubuntu
    ```
  - If you're behind a corporate firewall or proxy, configure your proxy settings:
    ```bash
    export http_proxy="http://proxy.example.com:port"
    export https_proxy="http://proxy.example.com:port"
    ```

- If you encounter "git is not installed" error:
  - The script should automatically install Git
  - If not, install Git manually before running the script:
    ```bash
    sudo apt update && sudo apt install git
    ```

- If you encounter issues changing your default shell, try:
  ```bash
  chsh -s $(which zsh)
  ```

- If Oh-My-Zsh plugins are not working, ensure your `.zshrc` includes them:
  ```bash
  plugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-completions zsh-history-substring-search)
  ```

- If PATH settings are not applied, restart your terminal or run:
  ```bash
  source ~/.zshrc
  ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
