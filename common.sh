#!/bin/bash

# ================================ VARIABLES ================================
# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
CHECK_MARK="\033[0;32m✓\033[0m"
X_MARK="\033[0;31m✗\033[0m"
ARROW="\033[0;34m➜\033[0m"

# Global variable to track if update has been run
UPDATE_RUN=false
# Flag to detect if running in Docker
RUNNING_IN_DOCKER=false
# Define supported OS array
OS=""
SUPPORTED_OS=(
    "ubuntu"
    "debian"
    "parrot os"
    "kali"
    "linux mint"
    "elementary os"
)
# Define version
VERSION="1.0.0"

# Timezone
TIMEZONE="Asia/Ho_Chi_Minh"

# ================================ END VARIABLES ================================

# ================================ FUNCTIONS ================================
# ================================ HELPER FUNCTIONS ================================
# Add version function
show_version() {
    echo -e "${GREEN}Script Version: ${VERSION}${NC}"
}

# Add help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -v, --version     Show script version"
    echo "  -h, --help        Show this help message"
}

# Functions to show different status
show_success() {
    local message="$1"
    echo -e "${CHECK_MARK} ${GREEN}${message}${NC}"
}

show_error() {
    local message="$1"
    echo -e "${X_MARK} ${RED}${message}${NC}"
}

show_info() {
    local message="$1"
    echo -e "${ARROW} ${message}"
}

# Function to check if running as root
is_root() {
    if [ "$(id -u)" -eq 0 ]; then
        return 0 # true
    else
        return 1 # false
    fi
}

# Function to handle command execution with or without sudo
# Example: run_with_sudo "apt-get update"
run_with_sudo() {
    local cmd="$@"
    
    # If running as root, don't use sudo
    if is_root; then
        eval "$cmd"
        return $?
    fi
    
    # Check if sudo is available
    if command -v sudo &> /dev/null; then
        sudo $cmd
        return $?
    else
        # If not running as root and sudo not available, show error
        show_error "Neither running as root nor sudo available. Cannot execute: $cmd"
        return 1
    fi
}

# Function to set timezone
set_timezone() {
    show_info "Setting timezone to $TIMEZONE"
    if command -v timedatectl &> /dev/null; then
        run_with_sudo "timedatectl set-timezone $TIMEZONE"
    else
        # Fallback method for systems without timedatectl
        echo "$TIMEZONE" | run_with_sudo "tee /etc/timezone"
        run_with_sudo "ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime"
    fi
    show_success "Timezone set to $TIMEZONE"
}

# Function to detect OS and package manager
# Example: detect_os
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VERSION=$VERSION_ID
        # Convert OS name to lowercase for easier comparison
        OS=$(echo "$OS" | tr '[:upper:]' '[:lower:]')
        # Handle special cases
        case $OS in
            "parrot security"|"parrot os")
                OS="parrot os"
                ;;
            "kali gnu/linux")
                OS="kali"
                ;;
            "debian gnu/linux")
                OS="debian"
                ;;
        esac
    elif [ -f /etc/debian_version ]; then
        OS="debian"
        VERSION=$(cat /etc/debian_version)
    elif [ -f /etc/redhat-release ]; then
        OS="red hat"
        VERSION=$(cat /etc/redhat-release)
    else
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        VERSION=$(uname -r)
    fi

    # Determine package manager
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt-get"
        UPDATE_CMD="apt-get update"
        INSTALL_CMD="apt-get install -y"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        UPDATE_CMD="dnf check-update"
        INSTALL_CMD="dnf install -y"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        UPDATE_CMD="yum check-update"
        INSTALL_CMD="yum install -y"
    else
        echo -e "${RED}Unsupported package manager${NC}"
        exit 1
    fi

    echo "Detected OS: $OS $VERSION"
    echo "Using package manager: $PKG_MANAGER"
}

# Function to run update if not already run
# Example: run_update
run_update() {
    if [ "$UPDATE_RUN" = false ]; then
        echo "Updating package lists..."
        run_with_sudo "$UPDATE_CMD"
        UPDATE_RUN=true
    fi
}

# Function to add PATH to .zshrc
# Example: add_path_to_zshrc "Go user bin PATH" "export PATH=\"\$PATH:\$HOME/.go/bin\""
add_path_to_zshrc() {
    local path_comment="$1"
    local path_export="$2"
    local zshrc_file="$HOME/.zshrc"
    
    # Create .zshrc if it doesn't exist
    if [ ! -f "$zshrc_file" ]; then
        touch "$zshrc_file"
    fi
    
    # Check if PATH already exists
    if ! grep -Fq "$path_export" "$zshrc_file"; then
        # Check if there's already a PATH export line
        if grep -q "export PATH" "$zshrc_file"; then
            # Add newline and PATH after the first PATH export line
            sed -i '/export PATH/a\# '"$path_comment"'\n'"$path_export" "$zshrc_file"
        else
            # No PATH export found, append to the end of file
            echo -e "\n# $path_comment\n$path_export" >> "$zshrc_file"
        fi
        show_success "Added $path_comment to .zshrc"
    else
        show_info "$path_comment already configured in .zshrc"
    fi
}

# Function to check if OS is supported
# Example: is_supported_os "ubuntu"
is_supported_os() {
    local check_os="$1"
    # Convert to lowercase and remove extra spaces
    check_os=$(echo "$check_os" | tr '[:upper:]' '[:lower:]' | tr -s ' ')
    echo "Checking OS: '$check_os'"
    
    # Check if OS exists in supported list
    if printf '%s\n' "${SUPPORTED_OS[@]}" | grep -q "^$check_os"; then
        return 0 # true
    fi
    return 1 # false
}

# ================================ INSTALL FUNCTIONS ================================
# Function to install library multiple language
# Example: install_library "go" "gobuster"
install_library() {
    # Install library multiple language
    case $1 in
        "go")
            install_go_library $2
            ;;
        "rust")
            install_rust_library $2
            ;;
        "python")
            install_python_library $2
            ;;
        "node")
            install_node_library $2
            ;;
        "all")
            show_error "Please install language first"
            exit 1
            ;;
    esac
}
# Function to install zsh
# Example: install_zsh
install_zsh() {
    # Check if zsh installed
    if ! command -v zsh &> /dev/null; then
        show_info "Installing zsh"
        # Install zsh based on package manager
        run_update
        run_with_sudo "$INSTALL_CMD zsh"
        show_success "zsh installed successfully"
    else
        show_success "zsh is already installed"
    fi

    # Change default shell to zsh
    show_info "Changing default shell to zsh"
    if [ "$SHELL" != "$(which zsh)" ]; then
        run_with_sudo "chsh -s $(which zsh) $USER"
        show_success "Default shell changed to zsh"
    else
        show_success "zsh is already the default shell"
    fi
}

# Function to configure Oh-My-Zsh
configure_oh_my_zsh() {
    local zshrc_file="$HOME/.zshrc"
    
    # Backup existing .zshrc if it's not a symlink
    if [ -f "$zshrc_file" ] && [ ! -L "$zshrc_file" ]; then
        cp "$zshrc_file" "$zshrc_file.backup_$(date +%Y%m%d_%H%M%S)"
        show_info "Backed up existing .zshrc file"
    fi
    
    # Check if plugins are configured
    if ! grep -q "plugins=(git" "$zshrc_file"; then
        show_info "Configuring Oh-My-Zsh plugins"
        # Find the plugins line and replace it
        if grep -q "plugins=" "$zshrc_file"; then
            sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-completions zsh-history-substring-search)/' "$zshrc_file"
        else
            # Add plugins if not found
            echo -e "\n# Oh-My-Zsh plugins\nplugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-completions zsh-history-substring-search)" >> "$zshrc_file"
        fi
        show_success "Oh-My-Zsh plugins configured"
    else
        # Check if all plugins are included
        if ! grep -q "plugins=.*zsh-syntax-highlighting" "$zshrc_file" || \
           ! grep -q "plugins=.*zsh-autosuggestions" "$zshrc_file" || \
           ! grep -q "plugins=.*zsh-completions" "$zshrc_file" || \
           ! grep -q "plugins=.*zsh-history-substring-search" "$zshrc_file"; then
            # Update plugins line to include all plugins
            sed -i 's/plugins=([^)]*)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-completions zsh-history-substring-search)/' "$zshrc_file"
            show_success "Updated Oh-My-Zsh plugins configuration"
        else
            show_success "Oh-My-Zsh plugins already configured"
        fi
    fi
}

# Function to install Git
install_git() {
    # Check if Git is installed
    if ! command -v git &> /dev/null; then
        show_info "Installing Git (required for Oh-My-Zsh)"
        run_update
        run_with_sudo "$INSTALL_CMD git"
        
        if [ $? -ne 0 ]; then
            show_error "Failed to install Git"
            return 1
        fi
        show_success "Git installed successfully"
    else
        show_success "Git is already installed"
    fi
    return 0
}

# Function to install Oh-My-Zsh
install_oh_my_zsh() {
    # First ensure Git is installed
    install_git || { show_error "Git is required for Oh-My-Zsh installation"; return 1; }
    
    local oh_my_zsh_dir="$HOME/.oh-my-zsh"
    local custom_dir="$oh_my_zsh_dir/custom/plugins"
    local zshrc_file="$HOME/.zshrc"
    
    # Create basic .zshrc file if it doesn't exist
    if [ ! -f "$zshrc_file" ]; then
        echo "# Basic .zshrc created by setup script" > "$zshrc_file"
        show_info "Created basic .zshrc file"
    fi
    
    # Check if Oh-My-Zsh installed
    if [ ! -d "$oh_my_zsh_dir" ]; then
        show_info "Installing Oh-My-Zsh"
        # Install Oh-My-Zsh with unattended mode
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        
        if [ $? -ne 0 ]; then
            show_error "Failed to install Oh-My-Zsh"
            return 1
        fi
        show_success "Oh-My-Zsh installed successfully"
    else
        show_success "Oh-My-Zsh is already installed"
    fi

    # Create custom plugins directory if it doesn't exist
    mkdir -p "$custom_dir"

    # Function to install plugin
    install_plugin() {
        local plugin_name="$1"
        local plugin_url="$2"
        local plugin_dir="$custom_dir/$plugin_name"
        
        if [ ! -d "$plugin_dir" ]; then
            show_info "Installing $plugin_name"
            git clone "$plugin_url" "$plugin_dir"
            if [ $? -ne 0 ]; then
                show_error "Failed to install $plugin_name"
                return 1
            fi
            show_success "$plugin_name installed successfully"
        else
            show_success "$plugin_name is already installed"
        fi
        return 0
    }

    # Install plugins
    install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git" || return 1
    install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git" || return 1
    install_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions.git" || return 1
    install_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search.git" || return 1
    
    # Configure Oh-My-Zsh
    configure_oh_my_zsh
    
    return 0
}

# Function to install Go
install_go() {
    # Install golang
    # Check if golang installed
    if ! command -v go &> /dev/null; then
        show_info "Installing Golang"
        run_update
        run_with_sudo "$INSTALL_CMD golang"
    else
        show_success "Golang is already installed"
    fi

    # Add Go PATHs to .zshrc
    add_path_to_zshrc "Go user bin PATH" "export PATH=\"\$PATH:\$HOME/.go/bin\""
    add_path_to_zshrc "Go system bin PATH" "export PATH=\"\$PATH:/usr/local/go/bin\""
}

# Function install curl
install_curl() {
    # Check if curl installed
    if ! command -v curl &> /dev/null; then
        show_info "Installing curl"
        run_with_sudo "$INSTALL_CMD curl"
    else
        show_success "curl is already installed"
    fi
}

# Function install wget
install_wget() {
    # Check if wget installed
    if ! command -v wget &> /dev/null; then
        show_info "Installing wget"
        run_with_sudo "$INSTALL_CMD wget"
    fi
}

# Function to install Rust
install_rust() {
    # Install rust
    # Check if rust installed
    if ! command -v rustc &> /dev/null; then
        show_info "Installing Rust"
        run_update
        run_with_sudo "$INSTALL_CMD rustc"
    else
        show_success "Rust is already installed"
    fi

    # Add Rust PATH to .zshrc
    add_path_to_zshrc "Rust PATH" "export PATH=\"\$PATH:\$HOME/.cargo/bin\""
}

# Function to install Python
install_python() {
    # Install python
    # Check if python or python3 installed
    if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
        show_info "Installing Python"
        run_update
        run_with_sudo "$INSTALL_CMD python3 python3-pip"
    else
        show_success "Python is already installed"
    fi

    # Add Python PATH to .zshrc
    add_path_to_zshrc "Python local bin PATH" "export PATH=\"\$PATH:\$HOME/.local/bin\""
}

# Function to install Node
install_node() {
    # Install node
    # Check if node installed
    if ! command -v node &> /dev/null; then
        show_info "Installing Node.js"
        run_update
        run_with_sudo "$INSTALL_CMD nodejs npm"
    else
        show_success "Node.js is already installed"
    fi

    # Add Node PATH to .zshrc
    add_path_to_zshrc "Node PATH" "export PATH=\"\$PATH:\$HOME/.node/bin\""
}

# Function to install library go
# Example: install_go_library "github.com/OJ/gobuster/v3@latest"
install_go_library() {
    # Check if go installed
    if ! command -v go &> /dev/null; then
        show_info "Installing Golang"
        install_go
    fi

    # Extract package name and version correctly
    if [[ "$1" == *"@"* ]]; then
        package_name=$(echo "$1" | rev | cut -d'/' -f1 | cut -d'@' -f2 | rev)
        version=$(echo "$1" | rev | cut -d'@' -f1 | rev)
    else
        package_name=$(echo "$1" | rev | cut -d'/' -f1 | rev)
        version="latest"
    fi

    # Check if binary exists in PATH
    if ! command -v "$package_name" &> /dev/null; then
        show_info "Installing $package_name:$version"
        go install "$1"
        
        # Check if installation was successful
        if [ $? -ne 0 ]; then
            show_error "Failed to install $package_name"
            return 1
        fi
        show_success "$package_name installed successfully"
    else
        show_success "$package_name:$version is already installed"
    fi
}

# Function to install library rust
# Example: install_rust_library "cargo-audit"
install_rust_library() {
    # Check if rust installed
    if ! command -v rustc &> /dev/null; then
        show_info "Installing Rust"
        install_rust
    fi
    # Install library rust
    # Check if library rust installed
    if ! command -v $1 &> /dev/null; then
        show_info "Installing $1"
        cargo install $1
    else
        show_success "$1 is already installed"
    fi
}

# Function to install library python
# Example: install_python_library "pip install sqlmap"
install_python_library() {
    # Check if python or python3 installed
    if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
        show_info "Installing Python"
        install_python
    fi
    # Install library python
    # Check if library python installed
    if ! command -v $1 &> /dev/null; then
        show_info "Installing $1"
        pip install $1
    else
        show_success "$1 is already installed"
    fi
}

# Function to install library node
# Example: install_node_library "npm install -g sqlmap"
install_node_library() {
    # Check if node installed
    if ! command -v node &> /dev/null; then
        show_info "Installing Node.js"
        install_node
    fi

    # Create .node directory if it doesn't exist
    mkdir -p "$HOME/.node"

    # Install library node
    # Check if library node installed
    if ! command -v $1 &> /dev/null; then
        show_info "Installing $1"
        # Install package locally for current user
        npm install -g --prefix ~/.node $1
        show_success "$1 installed successfully"
        
        # Add Node PATH to .zshrc if not already added
        if ! grep -q "\$HOME/.node/bin" "$HOME/.zshrc"; then
            add_path_to_zshrc "Node local bin PATH" "export PATH=\"\$PATH:\$HOME/.node/bin\""
        fi
    else
        show_success "$1 is already installed"
    fi
}

# Install package manager
install_package_manager() {
    # Install yarn
    if ! command -v yarn &> /dev/null; then
        show_info "Installing Yarn"
        if command -v npm &> /dev/null; then
            # Create .yarn directory if it doesn't exist
            mkdir -p "$HOME/.yarn"
            npm install -g --prefix ~/.node yarn
            if [ $? -ne 0 ]; then
                show_error "Failed to install yarn using npm"
                return 1
            fi
            show_success "Yarn installed successfully"
        else
            show_error "npm is required to install Yarn"
            return 1
        fi
    else
        show_success "Yarn is already installed"
    fi
    
    # Add Yarn PATH to .zshrc
    add_path_to_zshrc "Yarn PATH" "export PATH=\"\$PATH:\$HOME/.yarn/bin\""

    # Install pip if it's not already installed
    if ! command -v pip &> /dev/null && ! command -v pip3 &> /dev/null; then
        show_info "Installing pip"
        if command -v python3 &> /dev/null; then
            # Download and install pip
            curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
            python3 /tmp/get-pip.py --user
            if [ $? -ne 0 ]; then
                show_error "Failed to install pip"
                return 1
            fi
            rm /tmp/get-pip.py
            show_success "pip installed successfully"
        else
            show_error "Python3 is required to install pip"
            return 1
        fi
    else
        show_success "pip is already installed"
    fi
    
    # Add Pip PATH to .zshrc
    add_path_to_zshrc "Pip PATH" "export PATH=\"\$PATH:\$HOME/.local/bin\""
    
    return 0
}


# Function install language
install_language() {
    install_go
    install_rust
    install_python
    install_node
}

# Function bootstrap
bootstrap() {
    # Set timezone
    set_timezone

    # Run update
    run_update
}

# Main function
# Modify main function to handle arguments
main() {
    # Original main function code
    detect_os
    # check if os is supported
    if ! is_supported_os $OS; then
        show_error "Unsupported OS"
        exit 1
    fi

    # Detect environment (Docker or normal)
    if [ -f /.dockerenv ] || grep -q 'docker\|lxc' /proc/1/cgroup 2>/dev/null; then
        show_info "Docker environment detected, running in container mode"
        RUNNING_IN_DOCKER=true
    else
        RUNNING_IN_DOCKER=false
    fi

    # Check if running as root when not in Docker
    if is_root && [ "$RUNNING_IN_DOCKER" = false ]; then
        show_error "Please do not run this script as root when not in Docker"
        show_info "Run this script without sudo: ./$(basename $0)"
        exit 1
    fi

    # Show start message
    show_info "Starting setup on $OS $VERSION..."
    
    # Record start time
    local start_time=$(date +%s)

    bootstrap

    # Install required packages
    show_info "Installing required packages..."
    install_curl || { show_error "Failed to install curl"; exit 1; }
    install_wget || { show_error "Failed to install wget"; exit 1; }
    install_git || { show_error "Failed to install git"; exit 1; }
    install_zsh || { show_error "Failed to install zsh"; exit 1; }
    install_oh_my_zsh || { show_error "Failed to install Oh-My-Zsh"; exit 1; }
    
    show_info "Installing programming languages..."
    install_language || { show_error "Failed to install programming languages"; exit 1; }
    
    show_info "Installing package managers..."
    install_package_manager || { show_error "Failed to install package managers"; exit 1; }

    # Check exists folder /usr/sbin in .zshrc
    if ! grep -q "/usr/sbin" "$HOME/.zshrc"; then
        show_info "Adding /usr/sbin to PATH"
        add_path_to_zshrc "usr/sbin PATH" "export PATH=\"\$PATH:/usr/sbin\"" || { show_error "Failed to add /usr/sbin to PATH"; exit 1; }
    else
        show_success "/usr/sbin folder already exists in PATH"
    fi

    # Record end time and calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    
    # Apply changes to current shell
    show_info "==========================================="
    show_success "Setup completed successfully in ${minutes}m ${seconds}s!"
    show_info "-------------------------------------------"
    show_info "What to do now:"
    show_info "1. Run 'zsh' to start using your new shell configuration."
    show_info "2. Or restart your terminal to apply all changes."
    show_info "-------------------------------------------"
    show_info "Your development environment is ready!"
    show_info "==========================================="
}

# ================================ END FUNCTIONS ================================

# ================================ MAIN FUNCTION ================================
# Run the main function
# Handle command line arguments
case "$1" in
    -v|--version)
        show_version
        exit 0
        ;;
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac