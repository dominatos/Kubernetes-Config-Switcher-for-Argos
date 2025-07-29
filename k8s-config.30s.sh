#!/bin/bash
# Kubernetes Config Switcher for Argos
# Save this file as ~/.config/argos/k8s-config.30s.sh
# Make it executable: chmod +x ~/.config/argos/k8s-config.30s.sh

# Define the Kubernetes config directory
KUBE_DIR="$HOME/.kube"
# Define the active Kubernetes config file
CONFIG_FILE="$KUBE_DIR/config"

# Fix PATH to include common k9s locations
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Function to extract the cluster name from a kubeconfig file
# Arguments:
#   $1: Path to the kubeconfig file
# Returns:
#   The current context name if found, otherwise the first available context name, or "unknown".
get_cluster_name() {
    local config_file="$1"
    if [[ -f "$config_file" ]]; then
        # Attempt to find the current-context
        local current_context=$(grep "current-context:" "$config_file" | awk '{print $2}')
        if [[ -n "$current_context" ]]; then
            echo "$current_context"
        else
            # If current-context is not found, take the first available context
            local first_context=$(grep -A1 "contexts:" "$config_file" | grep "name:" | head -1 | awk '{print $2}')
            echo "${first_context:-unknown}"
        fi
    else
        echo "unknown"
    fi
}

# Function to switch the active Kubernetes configuration
# Arguments:
#   $1: The target kubeconfig file to activate
switch_config() {
    local target_config="$1"
    
    # Navigate to the .kube directory; exit if not found
    cd "$KUBE_DIR" || exit 1
    
    # If there's an active config, rename it based on its cluster name
    if [[ -f "config" ]]; then
        local current_cluster_name=$(get_cluster_name "config")
        mv "config" "config-${current_cluster_name}"
    fi
    
    # Activate the new config by renaming it to "config"
    mv "$target_config" "config"
    
    # Display a notification about the successful switch
    notify-send "Kubernetes" "Switched to $(get_cluster_name "config")" 2>/dev/null || true
}

# Function to open k9s (Kubernetes CLI UI) in a new terminal
open_k9s() {
    # Try to find k9s in common locations
    local k9s_path=""
    if [[ -x "$HOME/.local/bin/k9s" ]]; then
        k9s_path="$HOME/.local/bin/k9s"
    elif [[ -x "/usr/local/bin/k9s" ]]; then
        k9s_path="/usr/local/bin/k9s"
    elif command -v k9s >/dev/null 2>&1; then
        k9s_path="k9s"
    fi
    
    if [[ -n "$k9s_path" ]]; then
        # Open k9s in a new terminal, trying common terminal emulators
        if command -v gnome-terminal >/dev/null 2>&1; then
            gnome-terminal -- bash -c "export PATH='$PATH'; $k9s_path"
        elif command -v konsole >/dev/null 2>&1; then
            konsole -e bash -c "export PATH='$PATH'; $k9s_path"
        elif command -v xfce4-terminal >/dev/null 2>&1; then
            xfce4-terminal -e bash -c "export PATH='$PATH'; $k9s_path"
        elif command -v xterm >/dev/null 2>&1; then
            xterm -e bash -c "export PATH='$PATH'; $k9s_path"
        else
            # Notify if no supported terminal is found
            notify-send "Error" "No supported terminal found" 2>/dev/null || true
        fi
    else
        # Notify if k9s is not installed
        notify-send "Error" "k9s is not installed or not found in PATH" 2>/dev/null || true
    fi
}

# Handle command-line arguments for specific actions
if [[ "$1" == "switch" ]]; then
    switch_config "$2"
    exit 0
elif [[ "$1" == "k9s" ]]; then
    open_k9s
    exit 0
fi

# --- Main Argos Output Section ---

# Change to the .kube directory; if it doesn't exist, display an error and exit
cd "$KUBE_DIR" 2>/dev/null || {
    echo "❌ ~/.kube not found"
    exit 1
}

# Determine and display the currently active Kubernetes cluster
if [[ -f "config" ]]; then
    CURRENT_CLUSTER=$(get_cluster_name "config")
    echo "🔧 K8s: $CURRENT_CLUSTER"
else
    echo "🔧 K8s: No Config"
fi

echo "---"

# Display the active config status
if [[ -f "config" ]]; then
    echo "✅ $CURRENT_CLUSTER (active)"
else
    echo "❌ No active config"
fi

echo "---"

# List available Kubernetes configurations for switching
echo "Available Configs:"
# Iterate through files named "config-*" in the .kube directory
for config_file in config-*; do
    # Ensure it's a regular file and not the active "config" file itself
    if [[ -f "$config_file" && "$config_file" != "config" ]]; then
        # Get the cluster name from the config file
        cluster_name=$(get_cluster_name "$config_file")
        # Extract the display name from the filename (e.g., "my-cluster" from "config-my-cluster")
        display_name="${config_file#config-}"
        
        # If the cluster name differs from the display name, show both
        if [[ "$cluster_name" != "$display_name" && "$cluster_name" != "unknown" ]]; then
            echo "🔄 $display_name ($cluster_name) | bash='$0' param1=switch param2='$config_file' terminal=false refresh=true"
        else
            # Otherwise, just show the display name
            echo "🔄 $display_name | bash='$0' param1=switch param2='$config_file' terminal=false refresh=true"
        fi
    fi
done

# If no inactive configs are found, display a message
if ! ls config-* >/dev/null 2>&1; then
    echo "No available configs to switch"
fi

echo "---"

# Additional actions for the Argos menu
# Option to open k9s, only if there's an active config
if [[ -f "config" ]]; then
    # Check if k9s is available before showing the option
    if [[ -x "$HOME/.local/bin/k9s" ]] || [[ -x "/usr/local/bin/k9s" ]] || command -v k9s >/dev/null 2>&1; then
        echo "🚀 Open k9s | bash='$0' param1=k9s terminal=false"
    else
        echo "❌ k9s not found"
    fi
fi
# Option to open the .kube directory in a file manager
echo "📁 Open ~/.kube | bash='nautilus' param1='$KUBE_DIR' terminal=false"
# Option to refresh the Argos menu
echo "🔄 Refresh | refresh=true"
