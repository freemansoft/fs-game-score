#!/bin/zsh
# install-fvm.sh
# Usage: ./install-fvm.sh
# Installs fvm using brew
# Requires brew to be installed
# Requires zsh to be the shell
# Requires the user to have sudo privileges
# Requires the user to have permission to run brew commands
# Requires the user to have permission to run fvm commands
# Requires the user to have permission to run flutter commands
# Requires the user to have permission to run dart commands

if command -v brew >/dev/null 2>&1; then
    echo "brew is installed."
else
    echo "brew does not exist. Installing brew. Will require sudo privileges."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "brew installed."
    echo "quit this shell and start a new one to continue."
    exit 0
fi

if command -v brew >/dev/null 2>&1; then
    echo "Attempting to upgrade fvm using brew"
    brew upgrade fvm
else
    echo "Installing fvm using brew"
    brew tap leoafarias/fvm
    brew install
fi

echo "Current fvm version: $(fvm --version)"

fvm install 3.38.5
fvm use 3.38.5

# echo "You can change the flutter version using the following command:"
# echo "\e[34m fvm use <version>\e[0m"
# echo "For example:"
# echo "\e[34m fvm use 3.38.5\e[0m"
# echo "To list available versions:"
# echo "\e[34m fvm list\e[0m"
# echo "To install a specific version:"
# echo "\e[34m fvm install <version>\e[0m"
# echo "For example:"
# echo "\e[34m fvm install 3.38.5\e[0m"


