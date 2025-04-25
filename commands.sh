#!/usr/bin/env bash

# This file contains the registry of all available commands
# It is used to dynamically generate the command list and handle execution

# Define the command structure
# Format: command_name|description|script_file|default_args
declare -a COMMANDS=(
    "log|Display git log with interactive fzf interface|log|"
    "checkout|Checkout functionality|checkout|"
    # Add new commands here in the same format
    # "command_name|description|script_file|default_args"
)

# Get all command names
get_command_names() {
    local names=""
    for cmd_entry in "${COMMANDS[@]}"; do
        IFS='|' read -r name description file default_args <<<"$cmd_entry"
        names="$names $name"
    done
    echo "$names"
}

# Get description for a command
get_command_description() {
    local cmd_name=$1
    for cmd_entry in "${COMMANDS[@]}"; do
        IFS='|' read -r name description file default_args <<<"$cmd_entry"
        if [[ "$name" == "$cmd_name" ]]; then
            echo "$description"
            return 0
        fi
    done
    return 1
}

# Get file path for a command
get_command_file() {
    local cmd_name=$1
    for cmd_entry in "${COMMANDS[@]}"; do
        IFS='|' read -r name description file default_args <<<"$cmd_entry"
        if [[ "$name" == "$cmd_name" ]]; then
            echo "$file"
            return 0
        fi
    done
    return 1
}

# Get default args for a command
get_command_default_args() {
    local cmd_name=$1
    for cmd_entry in "${COMMANDS[@]}"; do
        IFS='|' read -r name description file default_args <<<"$cmd_entry"
        if [[ "$name" == "$cmd_name" ]]; then
            echo "$default_args"
            return 0
        fi
    done
    return 1
}

# Function to generate the command list for fzf
generate_command_list() {
    local temp_file=$1
    for cmd_entry in "${COMMANDS[@]}"; do
        IFS='|' read -r name description file default_args <<<"$cmd_entry"
        printf "%-12s - %s\n" "$name" "$description" >>"$temp_file"
    done
}

# Check if a command exists
command_exists() {
    local cmd_name=$1
    for cmd_entry in "${COMMANDS[@]}"; do
        IFS='|' read -r name description file default_args <<<"$cmd_entry"
        if [[ "$name" == "$cmd_name" ]]; then
            return 0
        fi
    done
    return 1
}

# Execute a command
execute_command() {
    local cmd_name=$1
    shift
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

    if command_exists "$cmd_name"; then
        local file=$(get_command_file "$cmd_name")
        local default_args=$(get_command_default_args "$cmd_name")

        # If default args are specified and no args provided, use defaults
        if [[ -n "$default_args" && $# -eq 0 ]]; then
            eval "$script_dir/$file $default_args"
        else
            "$script_dir/$file" "$@"
        fi
        return $?
    else
        echo "Unknown command: $cmd_name"
        return 1
    fi
}
