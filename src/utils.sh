#!/usr/bin/env bash

# Function to get the normalized GitHub repository URL
getGithubRepoUrl() {
  local base_url=$(git config --get remote.origin.url)
  base_url="${base_url/.git/}"

  if [[ $base_url =~ ^git@.* ]]; then
    base_url="${base_url/com:/com/}"
    base_url="${base_url/git@/http://}"
  fi

  echo "$base_url"
}

# Function to open a Github commit in the browser
openGithubCommitOnRemote() {
  read commit

  if [ ! -z "$commit" ]; then
    local base_url=$(getGithubRepoUrl)
    owner="wix-private"
    repo=$(basename $(git rev-parse --show-toplevel))
    open "$base_url/commit/$commit"
  fi
}

# Function to open a GitHub pull request from a commit
openPullRequestFromCommit() {
  read commit

  if [ ! -z "$commit" ]; then
    # Extract PR number from commit message
    local pr_number=$(git show -s --format='%s' $commit | grep -oE '\(#[0-9]+\)$' | grep -oE '[0-9]+')

    if [ ! -z "$pr_number" ]; then
      # Get repository URL
      local base_url=$(getGithubRepoUrl)

      # Open PR URL
      open "$base_url/pull/$pr_number"
      echo "${GREEN}✓${NORMAL} Opened PR #$pr_number"
      return 0
    else
      echo "${RED}✗${NORMAL} No PR number found in commit message"
      return 1
    fi
  fi
}

# Function to determine the main branch of a git repository
git_main_branch() {
  # Try symbolic-ref first (fast)
  local base_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

  # If symbolic-ref fails, check cache before using slower method
  if [ -z "$base_branch" ]; then
    # Get current repo path and cache file location
    local repo_path=$(git rev-parse --show-toplevel)
    local cache_file="$HOME/.glogm"

    # Check if cache file exists and try to find entry for current repo
    if [ -f "$cache_file" ]; then
      local cached_branch=$(grep "^$repo_path:" "$cache_file" | cut -d':' -f2)
      if [ ! -z "$cached_branch" ]; then
        echo "$cached_branch"
        return
      fi
    fi

    # If not in cache, use git remote show origin (slower but more reliable)
    base_branch=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')

    # Cache the result permanently
    if [ ! -z "$base_branch" ]; then
      # Create cache file if it doesn't exist
      touch "$cache_file"
      # Remove any existing entry for this repo
      sed -i.bak "/^$repo_path:/d" "$cache_file" 2>/dev/null
      # Add new entry
      echo "$repo_path:$base_branch" >>"$cache_file"
    fi
  fi

  echo "$base_branch"
}
