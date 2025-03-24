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

## System Requirements

- Supported Linux operating systems:
  - Ubuntu
  - Debian
  - Parrot OS
  - Kali Linux
  - Linux Mint
  - Elementary OS
- Internet connection
- Regular user with sudo privileges

## Usage

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

4. After installation:
   - Either run `zsh` to start using your new shell
   - Or restart your terminal to apply all changes

## What Happens During Installation

The script will:
1. Detect your operating system and package manager
2. Update package repositories
3. Set your timezone
4. Install essential tools (Git, curl, wget)
5. Install ZSH and make it your default shell
6. Install Oh-My-Zsh with useful plugins
7. Install Go, Rust, Python, and Node.js
8. Install Yarn and pip package managers
9. Configure PATH environment variables in `.zshrc`

## Important Notes

- The script should be run as a regular user (not as root)
- The script will prompt for your password when sudo is required
- The script checks if components are already installed before installing them
- Your existing `.zshrc` file will be backed up if changes are needed
- The script will show detailed progress and success/error messages

## Command Line Options

- `-v, --version`: Show script version
- `-h, --help`: Show help message

## Troubleshooting

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
