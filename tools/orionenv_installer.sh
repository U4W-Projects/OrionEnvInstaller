#!/bin/bash

FILENAME="orionenv"
GITHUB_REPO="U4W-Projects/U4W_OrionEnv_System"
BRANCH="main"
FILE_PATH_IN_REPO="orionenv"
TARGET_PATH="/home/$(whoami)/.local/bin/$FILENAME"

mkdir -p "$(dirname "$TARGET_PATH")"

echo "Select download method:"
echo "1) HTTPS with GitHub Personal Access Token"
echo "2) SSH (requires access and SSH key set up)"
read -rp "Enter your choice (1 or 2): " method

if [[ "$method" == "1" ]]; then
    echo "🔐 Enter your GitHub Personal Access Token:"
    read -rs GITHUB_TOKEN

    RAW_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$BRANCH/$FILE_PATH_IN_REPO"

    echo "⬇️  Downloading script via HTTPS..."
    curl -H "Authorization: token $GITHUB_TOKEN" -fsSL "$RAW_URL" -o "$TARGET_PATH"

    if [ $? -ne 0 ]; then
        echo "❌ Failed to download the script. Please check your token and URL."
        exit 1
    fi

elif [[ "$method" == "2" ]]; then
    echo "📡 Attempting SSH download via git archive..."

    TEMP_DIR=$(mktemp -d)
    pushd "$TEMP_DIR" >/dev/null

    # Clone the repo (shallow) and extract the file using git archive
    git clone --depth=1 --branch="$BRANCH" "git@github.com:$GITHUB_REPO.git" repo >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "❌ Failed to clone repo via SSH. Make sure your SSH key is configured with GitHub."
        popd >/dev/null
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    cp "repo/$FILE_PATH_IN_REPO" "$TARGET_PATH"
    if [ ! -f "$TARGET_PATH" ]; then
        echo "❌ File not found after SSH clone. Please check path: $FILE_PATH_IN_REPO"
        popd >/dev/null
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    popd >/dev/null
    rm -rf "$TEMP_DIR"

else
    echo "⚠️  Invalid choice. Please enter 1 or 2."
    exit 1
fi

chmod +x "$TARGET_PATH"

echo "✅ Installed to $TARGET_PATH"

# Check if ~/.local/bin is in PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo "⚠️  $HOME/.local/bin is not in your PATH."
    echo '👉 To fix, add this line to your ~/.bashrc or ~/.zshrc:'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
else
    echo "🚀 You can now run: $FILENAME"
fi
