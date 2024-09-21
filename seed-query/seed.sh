#!/bin/bash

# Clean up any previous runs
rm -rf seed-bot seed.sh

# Global variables
REPO_URL="https://github.com/arun993/seed-bot.git"
REPO_DIR="seed-bot/seed-query"
QUERY_FILE="query.txt"

# Function to check if Python 3.10+ is installed
check_python_version() {
    local python_version
    python_version=$(python3 --version 2>/dev/null | awk '{print $2}')
    
    if [[ -z "$python_version" || ! "$python_version" =~ ^3\.1[0-9] ]]; then
        printf "Python 3.10+ is required. Please install it and try again.\n" >&2
        return 1
    fi
}

# Function to install Python modules if not present
install_python_modules() {
    if ! pip3 show requests colorama &>/dev/null; then
        printf "Installing required Python modules...\n"
        pip3 install requests colorama || {
            printf "Failed to install required Python modules.\n" >&2
            return 1
        }
    fi
}

# Function to clone the repository
clone_repo() {
    if [[ -d "$REPO_DIR" ]]; then
        printf "Directory '%s' already exists, skipping clone.\n" "$REPO_DIR"
    else
        printf "Cloning repository...\n"
        git clone "$REPO_URL" && cd "$REPO_DIR" || {
            printf "Failed to clone repository or navigate to directory.\n" >&2
            return 1
        }
    fi
}

# Function to ask for user input and save it to a file
save_user_input() {
    printf "Enter query IDs and press Ctrl+D when done:\n"
    if ! cat > "$QUERY_FILE"; then
        printf "Failed to save user input to '%s'.\n" "$QUERY_FILE" >&2
        return 1
    fi
    printf "Query saved to '%s'.\n" "$QUERY_FILE"
}

# Function to run the Python script
run_python_script() {
    if [[ -f "seed.py" ]]; then
        python3 seed.py || {
            printf "Failed to run the Python script.\n" >&2
            return 1
        }
    else
        printf "'seed.py' not found in the repository.\n" >&2
        return 1
    fi
}

# Main function
main() {
    check_python_version || exit 1
    install_python_modules || exit 1
    clone_repo || exit 1
    save_user_input || exit 1
    run_python_script || exit 1
}

# Execute main function
main
