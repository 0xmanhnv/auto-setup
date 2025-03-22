#!/bin/bash
# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Global variable to track if update has been run
UPDATE_RUN=false

# ================================ FUNCTIONS ================================
# ================================ HELPER FUNCTIONS ================================
# Function to detect OS and package manager
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VERSION=$VERSION_ID
        # Convert OS name to lowercase for easier comparison
        OS=$(echo "$OS" | tr '[:upper:]' '[:lower:]')
        # Handle special cases
        case $OS in
            "parrot security")
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
run_update() {
    if [ "$UPDATE_RUN" = false ]; then
        echo "Updating package lists..."
        sudo $UPDATE_CMD
        UPDATE_RUN=true
    fi
}

# Function to add PATH to .zshrc
add_path_to_zshrc() {
    local path_comment="$1"
    local path_export="$2"
    
    # Check if PATH already exists
    if ! grep -Fq "$path_export" ~/.zshrc; then
        # Add newline and PATH after the first PATH export line
        sed -i '/# export PATH=/a\# '"$path_comment"'\n'"$path_export" ~/.zshrc
    else
        echo -e "${GREEN}$path_comment already configured in .zshrc${NC}"
    fi
}

# ================================ INSTALL FUNCTIONS ================================
# Function to install zsh
install_zsh() {
    # Check if zsh installed
    if ! command -v zsh &> /dev/null; then
        echo "Installing zsh"
        # Install zsh based on package manager
        run_update
        sudo $INSTALL_CMD zsh
    else
        echo -e "${GREEN}zsh is already installed${NC}"
    fi
    # Change default shell to zsh
    echo "Y" | sudo chsh -s $(which zsh)
    zsh
}

# Function to install Oh-My-Zsh
install_oh_my_zsh() {
    # Check if Oh-My-Zsh installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh-My-Zsh"
        # Install Oh-My-Zsh with unattended mode and keep existing .zshrc
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    else
        echo -e "${GREEN}Oh-My-Zsh is already installed${NC}"
    fi

    # Check if zsh-syntax-highlighting installed
    if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        echo "Installing zsh-syntax-highlighting"
        # Install zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    else
        echo -e "${GREEN}zsh-syntax-highlighting is already installed${NC}"
    fi

    # Check if zsh-autosuggestions installed
    if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        echo "Installing zsh-autosuggestions"
        # Install zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    else
        echo -e "${GREEN}zsh-autosuggestions is already installed${NC}"
    fi

    # Check if zsh-completions installed
    if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions" ]; then
        echo "Installing zsh-completions"
        # Install zsh-completions
        git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
    else
        echo -e "${GREEN}zsh-completions is already installed${NC}"
    fi

    # Check if zsh-history-substring-search installed
    if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search" ]; then
        echo "Installing zsh-history-substring-search"
        # Install zsh-history-substring-search
        git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    else
        echo -e "${GREEN}zsh-history-substring-search is already installed${NC}"
    fi
}

# Function install language
install_language() {
    # Install golang
    # Check if golang installed
    if ! command -v go &> /dev/null; then
        echo "Installing Golang"
        case $OS in
            "ubuntu"|"debian"|"parrot os"|"kali"|"linux mint"|"elementary os")
                run_update
                sudo $INSTALL_CMD golang
                ;;
            *)
                echo -e "${RED}Unsupported OS for Golang installation${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}Golang is already installed${NC}"
    fi

    # Add Go PATHs to .zshrc
    add_path_to_zshrc "Go user bin PATH" "export PATH=\"\$PATH:\$HOME/.go/bin\""
    add_path_to_zshrc "Go system bin PATH" "export PATH=\"\$PATH:/usr/local/go/bin\""

    # Install rust
    # Check if rust installed
    if ! command -v rustc &> /dev/null; then
        echo "Installing Rust"
        case $OS in
            "ubuntu"|"debian"|"parrot os"|"kali"|"linux mint"|"elementary os")
                run_update
                sudo $INSTALL_CMD rustc
                ;;
            *)
                echo -e "${RED}Unsupported OS for Rust installation${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}Rust is already installed${NC}"
    fi

    # Add Rust PATH to .zshrc
    add_path_to_zshrc "Rust PATH" "export PATH=\"\$PATH:\$HOME/.cargo/bin\""

    # Install python
    # Check if python installed
    if ! command -v python &> /dev/null; then
        echo "Installing Python"
        case $OS in
            "ubuntu"|"debian"|"parrot os"|"kali"|"linux mint"|"elementary os")
                run_update
                sudo $INSTALL_CMD python3 python3-pip
                ;;
            *)
                echo -e "${RED}Unsupported OS for Python installation${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}Python is already installed${NC}"
    fi

    # Add Python PATH to .zshrc
    add_path_to_zshrc "Python local bin PATH" "export PATH=\"\$PATH:\$HOME/.local/bin\""

    # Install node
    # Check if node installed
    if ! command -v node &> /dev/null; then
        echo "Installing Node.js"
        case $OS in
            "ubuntu"|"debian"|"parrot os"|"kali"|"linux mint"|"elementary os")
                run_update
                sudo $INSTALL_CMD nodejs npm
                ;;
            *)
                echo -e "${RED}Unsupported OS for Node.js installation${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}Node is already installed${NC}"
    fi

    # Add Node PATH to .zshrc
    add_path_to_zshrc "Node PATH" "export PATH=\"\$PATH:\$HOME/.node/bin\""
}

# Function install library
install_library() {
    # Install yarn
    # Check if yarn installed
    if ! command -v yarn &> /dev/null; then
        echo "Installing Yarn"
        case $OS in
            "ubuntu"|"debian"|"parrot os"|"kali"|"linux mint"|"elementary os")
                run_update
                sudo $INSTALL_CMD yarn
                ;;
            *)
                echo -e "${RED}Unsupported OS for Yarn installation${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}Yarn is already installed${NC}"
    fi

    # Add Yarn PATH to .zshrc
    add_path_to_zshrc "Yarn PATH" "export PATH=\"\$PATH:\$HOME/.yarn/bin\""

    # Install pip
    # Check if pip installed
    if ! command -v pip &> /dev/null; then
        echo "Installing pip"
        case $OS in
            "ubuntu"|"debian"|"parrot os"|"kali"|"linux mint"|"elementary os")
                run_update
                sudo $INSTALL_CMD python3-pip
                ;;
            *)
                echo -e "${RED}Unsupported OS for pip installation${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}Pip is already installed${NC}"
    fi

    # Add Pip PATH to .zshrc
    add_path_to_zshrc "Pip PATH" "export PATH=\"\$PATH:\$HOME/.local/bin\""
}

# Main function
main() {
    # Detect OS and package manager
    detect_os

    # Run initial update
    run_update

    # Install zsh
    install_zsh

    # Install Oh-My-Zsh
    install_oh_my_zsh

    # Install language
    install_language

    # Install library
    install_library

    # Source .zshrc to apply changes
    echo "Applying changes to current shell..."
    source ~/.zshrc
}
# ================================ END FUNCTIONS ================================

# ================================ MAIN FUNCTION ================================
# Run the main function
main
