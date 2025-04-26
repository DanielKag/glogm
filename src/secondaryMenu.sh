#!/usr/bin/env bash

# Function to handle actions on a selected commit
handle_commit_actions() {
    local commit_hash="$1"

    # Get commit details
    local author=$(git show -s --format='%an' $commit_hash)
    local commit_date=$(git show -s --format='%cr' $commit_hash)
    local commit_message=$(git show -s --format='%s' $commit_hash)

    # Create a single line header with commit details, matching log colors
    # Bold dim cyan for hash, Green for date, Bold blue for author
    local header_text="${CYAN}${commit_hash}${NORMAL} ${GREEN}${commit_date}${NORMAL} ${BOLD}${BLUE}${author}${NORMAL} ${commit_message}"

    # Create temporary file for the menu
    local temp_menu=$(mktemp)
    # Add separator
    echo -e "----------------------------------------" >"$temp_menu"
    echo -e "${BLUE}Open in Github${NORMAL}" >>"$temp_menu"
    echo -e "${GREEN}Copy commit hash${NORMAL}" >>"$temp_menu"
    echo -e "${YELLOW}Revert commit${NORMAL}" >>"$temp_menu"

    # Create preview command to show the commit diff
    local preview_cmd="git show --color=always $commit_hash | delta"

    # Show the action menu with fzf
    local action=$(cat "$temp_menu" | fzf --ansi \
        --no-multi \
        --header="$header_text" \
        --header-lines=1 \
        --preview="$preview_cmd" \
        --preview-window=right:60% \
        --bind="esc:abort")

    # Clean up
    rm "$temp_menu"

    # If ESC was pressed (no selection), return to main log
    if [ -z "$action" ]; then
        show_log
        return
    fi

    # Process the selected action
    if [[ "$action" == *"Open in Github"* ]]; then
        # Open in Github
        openGithubCommitOnRemote <<<"$commit_hash"
    elif [[ "$action" == *"Copy commit hash"* ]]; then
        # Copy commit hash to clipboard
        echo -n "$commit_hash" | pbcopy
        echo "${GREEN}✓${NORMAL} Commit hash copied to clipboard: $commit_hash"
    elif [[ "$action" == *"Revert commit"* ]]; then
        # Create revert command and copy to clipboard
        local revert_cmd="git revert $commit_hash"
        echo -n "$revert_cmd" | pbcopy
        echo "${YELLOW}!${NORMAL} Revert command copied to clipboard: $revert_cmd"
        echo "Paste and run the command to revert the commit."
    fi
} 