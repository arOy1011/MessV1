{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Mess GitHub Auto Sync",
      "type": "shell",
      "command": "${workspaceFolder}/auto_sync.sh",
      "isBackground": true,
      "runOptions": {
        "runOn": "folderOpen"
      },
      "presentation": {
        "reveal": "silent",
        "panel": "dedicated",
        "showReuseMessage": false,
        "clear": false
      },
      "problemMatcher": []
    }
  ]
}

#!/bin/bash

cd "$(dirname "$0")" || exit 1

BRANCH="master"
INTERVAL=15
REMOTE="origin"

echo "Mess GitHub two-way auto-sync started."
echo "Remote: $REMOTE | Branch: $BRANCH | Interval: ${INTERVAL}s"
echo "Both contributors can run this same script."
echo "Press Ctrl+C to stop."

has_git_operation() {
    [ -d ".git/rebase-merge" ] || \
    [ -d ".git/rebase-apply" ] || \
    [ -f ".git/MERGE_HEAD" ] || \
    [ -f ".git/CHERRY_PICK_HEAD" ]
}

commit_local_changes() {
    if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        echo "[$(date '+%H:%M:%S')] Local changes detected. Committing..."
        git add -A
        if ! git diff --cached --quiet; then
            git commit -m "Auto sync $(date '+%Y-%m-%d %H:%M:%S')" || return 1
        fi
    fi
    return 0
}

sync_once() {
    echo "[$(date '+%H:%M:%S')] Syncing..."

    if has_git_operation; then
        echo "Git merge/rebase operation is unfinished. Resolve it manually."
        return 1
    fi

    if ! commit_local_changes; then
        echo "Could not commit local changes."
        return 1
    fi

    if ! git fetch "$REMOTE" "$BRANCH"; then
        echo "Could not reach GitHub. Will retry next cycle."
        return 1
    fi

    if ! git rebase "$REMOTE/$BRANCH"; then
        echo "Conflict while incorporating collaborator changes. Resolve it manually."
        return 1
    fi

    if git push "$REMOTE" "$BRANCH"; then
        echo "[$(date '+%H:%M:%S')] Sync complete."
        return 0
    fi

    echo "Push was rejected; refreshing GitHub and retrying once..."
    if git fetch "$REMOTE" "$BRANCH" && git rebase "$REMOTE/$BRANCH" && git push "$REMOTE" "$BRANCH"; then
        echo "[$(date '+%H:%M:%S')] Sync complete after retry."
        return 0
    fi

    echo "Retry failed. No force push attempted."
    return 1
}

while true; do
    sync_once
    sleep "$INTERVAL"
done