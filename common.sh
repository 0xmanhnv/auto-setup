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

# Function to set timezone
set_timezone() {
    show_info "Setting timezone to $TIMEZONE"
    if command -v timedatectl &> /dev/null; then
        sudo timedatectl set-timezone $TIMEZONE
    else
        # Fallback method for systems without timedatectl
        echo "$TIMEZONE" | sudo tee /etc/timezone
        sudo ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
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
        sudo $UPDATE_CMD
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
        # Add newline and PATH after the first PATH export line
        sed -i '/# export PATH=/a\# '"$path_comment"'\n'"$path_export" "$zshrc_file"
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
    for os in "${SUPPORTED_OS[@]}"; do
        echo "Comparing with: '$os'"
        if [ "$os" = "$check_os" ]; then
            return 0 # true
        fi
    done
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
        sudo $INSTALL_CMD zsh
    else
        show_success "zsh is already installed"
    fi
    # Change default shell to zsh
    echo "Y" | sudo chsh -s $(which zsh)
}

# Function to install Oh-My-Zsh
install_oh_my_zsh() {
    local oh_my_zsh_dir="$HOME/.oh-my-zsh"
    local custom_dir="$oh_my_zsh_dir/custom/plugins"
    
    # Check if Oh-My-Zsh installed
    if [ ! -d "$oh_my_zsh_dir" ]; then
        show_info "Installing Oh-My-Zsh"
        # Install Oh-My-Zsh with unattended mode
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
        else
            show_success "$plugin_name is already installed"
        fi
    }

    # Install plugins
    install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
    install_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions.git"
    install_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search.git"
}

# Function to install Go
install_go() {
    # Install golang
    # Check if golang installed
    if ! command -v go &> /dev/null; then
        show_info "Installing Golang"
        run_update
        sudo $INSTALL_CMD golang
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
        sudo $INSTALL_CMD curl
    else
        show_success "curl is already installed"
    fi
}

# Function install wget
install_wget() {
    # Check if wget installed
    if ! command -v wget &> /dev/null; then
        show_info "Installing wget"
        sudo $INSTALL_CMD wget
    fi
}

# Function to install Rust
install_rust() {
    # Install rust
    # Check if rust installed
    if ! command -v rustc &> /dev/null; then
        show_info "Installing Rust"
        run_update
        sudo $INSTALL_CMD rustc
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
        sudo $INSTALL_CMD python3 python3-pip
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
        sudo $INSTALL_CMD nodejs npm
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

    # echo with name package not full path, example: "gobuster" not "github.com/OJ/gobuster/v3@latest"
    package_name=$(echo $1 | rev | cut -d'/' -f1 | rev)
    version=$(echo $1 | rev | cut -d'@' -f1 | rev)

    # Install library go
    # Check if library go installed
    if ! command -v $package_name &> /dev/null; then
        
        show_info "Installing $package_name:$version"
        go install $1
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
    # Install library node
    # Check if library node installed
    if ! command -v $1 &> /dev/null; then
        show_info "Installing $1"
        npm install -g $1
    else
        show_success "$1 is already installed"
    fi
}

# Install package manager
install_package_manager() {
    # Install yarn
    # Check if yarn installed and supported os
    if ! command -v yarn &> /dev/null; then
        show_info "Installing Yarn"
        install_node_library "yarn"
    else
        show_success "yarn is already installed"
    fi
    # Add Yarn PATH to .zshrc
    add_path_to_zshrc "Yarn PATH" "export PATH=\"\$PATH:\$HOME/.yarn/bin\""

    # Install pip
    # Check if pip installed and supported os
    if ! command -v pip &> /dev/null; then
        show_info "Installing pip"
        install_python_library "pip"
    else
        show_success "pip is already installed"
    fi
    # Add Pip PATH to .zshrc
    add_path_to_zshrc "Pip PATH" "export PATH=\"\$PATH:\$HOME/.local/bin\""
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
    # Check /usr/sbin in PATH
    if ! command -v /usr/sbin &> /dev/null; then
        show_info "Adding /usr/sbin to PATH"
        add_path_to_zshrc "usr/sbin PATH" "export PATH=\"\$PATH:/usr/sbin\""
    else
        show_success "/usr/sbin is already in PATH"
    fi

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
    bootstrap

    # Install required packages
    install_curl
    install_wget
    install_zsh
    install_oh_my_zsh
    install_language
    install_package_manager

    # Apply changes to current shell
    show_info "Setup completed successfully!"
    show_info "Please run 'zsh' to start using your new shell configuration."
    show_info "Or restart your terminal to apply all changes."
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