#!/bin/bash

echo "🔐 Enter your GitHub Personal Access Token:"
read -rs GITHUB_TOKEN

RAW_URL="https://raw.githubusercontent.com/U4W-Projects/U4W_OrionEnv_System/refs/heads/main/orionenv"
TARGET_PATH="/home/$(whoami)/.local/bin/orionenv"

mkdir -p /home/$(whoami)/.local/bin

echo "⬇️  Downloading script..."
curl -H "Authorization: token $GITHUB_TOKEN" -fsSL "$RAW_URL" -o "$TARGET_PATH"

if [ $? -ne 0 ]; then
    echo "❌ Failed to download the script. Please check your token and URL."
    exit 1
fi

chmod +x "$TARGET_PATH"

echo "✅ Installed to $TARGET_PATH"

# Check if ~/.local/bin is in PATH
if ! echo "$PATH" | grep -q "/home/$(whoami)/.local/bin"; then
    echo "⚠️  /home/$(whoami)/.local/bin is not in your PATH."
    echo '👉 To fix, add this line to your ~/.bashrc or ~/.zshrc:'
    echo 'export PATH="/home/$(whoami)/.local/bin:$PATH"'
else
    echo "🚀 You can now run: orionenv"
fi
