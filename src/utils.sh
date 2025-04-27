#!/usr/bin/env bash

# Function to open a Github commit in the browser
openGithubCommitOnRemote() {
  base_url=$(git config --get remote.origin.url)
  base_url="${base_url/.git/}"

  if [[ $base_url=~^git@.* ]]; then
    base_url="${base_url/com:/com/}"
    base_url="${base_url/git@/http://}"
  fi
  
  read commit
  
  if [ ! -z "$commit" ]; then
    owner="wix-private"
    repo=$(basename $(git rev-parse --show-toplevel))
    open "$base_url/commit/$commit"
  fi
}

# Function to determine the main branch of a git repository
git_main_branch() {
  base_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  
  if [ ! -z "$base_branch" ]; then
    echo $base_branch
  else
    def=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
    echo $def
  fi
} 