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
    if ! git diff --quiet || \
       ! git diff --cached --quiet || \
       [ -n "$(git ls-files --others --exclude-standard)" ]; then

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
        echo "Git merge/rebase operation is unfinished."
        echo "Resolve it manually. Auto-sync is paused for this cycle."
        return 1
    fi

    # Protect local work before incorporating the collaborator's commits.
    if ! commit_local_changes; then
        echo "Could not commit local changes."
        return 1
    fi

    # Refresh knowledge of GitHub before rebasing.
    if ! git fetch "$REMOTE" "$BRANCH"; then
        echo "Could not reach GitHub. Will retry next cycle."
        return 1
    fi

    # Put our local commits on top of the latest collaborator commits.
    if ! git rebase "$REMOTE/$BRANCH"; then
        echo "A conflict occurred while incorporating collaborator changes."
        echo "Resolve the conflict manually, then run: git add <files> && git rebase --continue"
        echo "Auto-sync will never force-push over the collaborator's work."
        return 1
    fi

    # Upload our resulting branch.
    if git push "$REMOTE" "$BRANCH"; then
        echo "[$(date '+%H:%M:%S')] Sync complete."
        return 0
    fi

    # The collaborator may have pushed between our fetch and push.
    echo "Push changed while syncing. Checking GitHub once more..."

    if ! git fetch "$REMOTE" "$BRANCH"; then
        echo "Second GitHub fetch failed. Will retry next cycle."
        return 1
    fi

    if ! git rebase "$REMOTE/$BRANCH"; then
        echo "Conflict occurred during push-race recovery."
        echo "Resolve it manually. No force push will be attempted."
        return 1
    fi

    if git push "$REMOTE" "$BRANCH"; then
        echo "[$(date '+%H:%M:%S')] Sync complete after retry."
        return 0
    fi

    echo "Push still failed. Leaving repository untouched until the next cycle."
    return 1
}

while true; do
    sync_once
    sleep "$INTERVAL"
done
