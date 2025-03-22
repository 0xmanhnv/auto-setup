# Auto Setup Scripts

Scripts for automatically installing and configuring development environment and pentest tools on Linux.

## Directory Structure

```
.
├── common.sh              # Script for installing basic tools
├── install_pentest_tools.sh  # Script for installing pentest tools
└── README.md             # This guide file
```

## Features

### common.sh
- Install and configure ZSH with Oh-My-Zsh
- Install programming languages:
  - Go
  - Rust
  - Python
  - Node.js
- Install libraries:
  - Yarn
  - pip
- Automatically configure PATH in .zshrc
- Support for multiple Linux operating systems

### install_pentest_tools.sh
- Inherits all features from common.sh
- Installs additional pentest tools:
  - System tools:
    - nmap: Network and security scanning
    - gobuster: Web directory scanning
    - dirb: Web directory scanning
    - nikto: Web vulnerability scanning
    - hydra: Password cracking
    - sqlmap: SQL injection exploitation
    - metasploit-framework: Vulnerability exploitation framework
  - Go-based tools:
    - fff: Fast File Finder
    - waybackurls: Find URLs from Wayback Machine
    - assetfinder: Find subdomains
    - gf: Pattern matching
    - httprobe: Check HTTP/HTTPS endpoints
    - meg: Parallel HTTP requests
    - qsreplace: Query string replacement
    - unfurl: URL analysis
    - anew: Add new lines to file
    - gron: Work with JSON
  - Python-based tools (in virtual environment):
    - subfinder: Find subdomains
    - amass: Security scanning
    - dnsrecon: DNS analysis
    - massdns: Fast DNS scanning
    - dnsvalidator: DNS validation
    - dnsgen: DNS generation
    - altdns: DNS alternation
    - masscan: Fast port scanning
    - ffuf: Web fuzzing
    - nuclei: Vulnerability scanning
    - httpx: HTTP toolkit
    - subjack: Subdomain takeover
    - waybackpy: Wayback Machine API
    - dalfox: XSS scanner
    - gf-patterns: Pattern matching
    - hakrawler: Crawler

## System Requirements

- Supported Linux operating systems:
  - Ubuntu
  - Debian
  - Parrot OS
  - Kali Linux
  - Linux Mint
  - Elementary OS
- Sudo privileges for package installation
- Internet connection for downloading packages

## Usage

1. Download the scripts:
```bash
git clone <repository-url>
cd <repository-name>
```

2. Make scripts executable:
```bash
chmod +x common.sh install_pentest_tools.sh
```

3. Run scripts:

- To install basic tools:
```bash
sudo ./common.sh
```

- To install pentest tools (includes basic tools):
```bash
sudo ./install_pentest_tools.sh
```

4. After installation:
```bash
# Switch to zsh shell
zsh

# Python tools will be automatically activated in virtual environment
# Check installation:
which fff  # Go tool
which subfinder  # Python tool
```

## Important Notes

1. Scripts will automatically:
   - Detect operating system
   - Install appropriate tools
   - Configure PATH in .zshrc
   - Create Python virtual environment for pentest tools
   - Apply changes to current shell

2. If a tool is already installed:
   - Script will display green message
   - Tool will not be reinstalled

3. If you encounter errors:
   - Check sudo privileges
   - Check internet connection
   - Check logs for detailed error information
   - Ensure you're using zsh shell

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a new branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License

```bash
sudo apt update && sudo apt install zsh
chsh -s $(which zsh)
```

- Install Oh-My-Zsh

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
