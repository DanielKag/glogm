#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Source utils and consts from current directory
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/consts.sh"
source "$SCRIPT_DIR/secondaryMenu.sh"

# Main log view function
show_log() {
    base_branch=$(git_main_branch)
    remote_base_branch="origin/$base_branch"
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    command_head="git -c color.ui=always log HEAD \
                --decorate-refs-exclude=refs/tags --abbrev-commit \
                --pretty=format:'%C(bold dim cyan)%h%Creset %C(green)%<(13)%cr%Creset %C(bold blue)%<(16)%an%Creset %s %C(auto)%d%Creset'"

    command_master="git -c color.ui=always log $remote_base_branch \
                --decorate-refs-exclude=refs/tags --abbrev-commit \
                --pretty=format:'%C(bold dim cyan)%h%Creset %Cgreen%<(13)%cr%Creset %C(bold blue)%<(16)%an%Creset %s %C(auto)%d%Creset'"

    header=$(printf "<Tab>    Toggle commit diff\n<Enter>  Show action menu\n<R> Refresh\n← →      Choose branch")
    head_prompt="${INVERT}${current_branch} (HEAD) ${NORMAL} ${remote_base_branch}"
    base_prompt="${current_branch} (HEAD) ${INVERT}${remote_base_branch}${NORMAL}"

    # Get selected commit
    selected_commit=$(eval "echo '$head_prompt'; $command_head" |
        fzf --ansi --no-sort --exact \
            --header "$header" \
            --header-lines=1 \
            --prompt="Type to search: " \
            --reverse \
            --bind='tab:toggle-preview' \
            --bind "R:reload(git fetch && echo '$base_prompt'; $command_master)" \
            --bind "left:reload(echo '$head_prompt'; $command_head)" \
            --bind "right:reload(echo '$base_prompt'; $command_master)" \
            --preview-window right \
            --preview-window hidden \
            --preview 'git show {1} | delta' |
        cut -d\  -f 1)

    # If a commit was selected, handle actions
    if [ -n "$selected_commit" ]; then
        handle_commit_actions "$selected_commit"
    fi
}

# Start the log view
show_log
