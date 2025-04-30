#!/bin/bash

# Function to validate GitHub URL (basic)
validate_url() {
    if [[ "$1" =~ ^(https:\/\/|git@)github\.com[:\/][A-Za-z0-9._-]+\/[A-Za-z0-9._-]+(\.git)?$ ]]; then
        return 0
    else
        return 1
    fi
}

echo "Enter the name of your project:"
read -r project_name

# Check if directory already exists
if [ -d "$project_name" ]; then
    echo "❌ Error: A directory named '$project_name' already exists. Please choose another name."
    exit 1
fi

# Input and validate GitHub repo URL
while true; do
    echo "Enter the GitHub repository URL (HTTPS or SSH):"
    read -r repo_url

    if validate_url "$repo_url"; then
        break
    else
        echo "⚠️  Invalid GitHub URL format. Please enter a valid HTTPS or SSH GitHub URL."
    fi
done

# Select clone method
while true; do
    echo "Choose the method to clone:"
    echo "1) HTTPS"
    echo "2) SSH"
    read -rp "Enter your choice (1 or 2): " method

    if [[ "$method" == "1" ]]; then
        if [[ "$repo_url" =~ ^https:// ]]; then
            clone_url="$repo_url"
        else
            echo "⚠️  Provided URL is not an HTTPS URL."
            continue
        fi
        break
    elif [[ "$method" == "2" ]]; then
        if [[ "$repo_url" =~ ^git@ ]]; then
            echo "🔐 Ensure your SSH key is added to your SSH agent and GitHub account."
            read -rp "Press Enter to continue when you're ready..."
            clone_url="$repo_url"
            break
        else
            echo "⚠️  Provided URL is not an SSH URL."
            continue
        fi
    else
        echo "⚠️  Invalid choice. Please enter 1 or 2."
    fi
done

# Try to clone
echo "📦 Cloning repository..."
if git clone "$clone_url" "$project_name"; then
    echo "✅ Repository cloned successfully into '$project_name'."
else
    echo "❌ Failed to clone the repository."
    exit 1
fi

# Remove the .git folder
if [ -d "$project_name/.git" ]; then
    rm -rf "$project_name/.git"
    echo "🧹 Removed .git directory. The project is now a clean working directory."
else
    echo "⚠️  .git directory not found. Nothing to remove."
fi

echo "🎉 Setup complete!"
