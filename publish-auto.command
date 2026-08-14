#!/bin/bash
# =============================================================================
# PALIO — AUTOMATIC PUBLISH
# =============================================================================
# The unattended twin of publish.command. Same job — send whatever is in this
# folder to GitHub — but it asks no questions, because nobody is watching when
# it runs. A launchd agent starts it a few minutes after each scheduled news
# refresh writes new files here.
#
# It uses the GitHub sign-in already stored in this Mac's keychain. Nothing in
# here asks for, stores, or handles a password or token.
#
# Everything it does is written to:
#   ~/Library/Logs/palio-publish.log
# =============================================================================

cd "$(dirname "$0")" || exit 1

LOG="$HOME/Library/Logs/palio-publish.log"
mkdir -p "$(dirname "$LOG")"

# Timestamp every run so the log reads as a history rather than a jumble.
say(){ echo "$(date '+%Y-%m-%d %H:%M:%S')  $*" >> "$LOG"; }

say "---- run start ----"

# --- Is this actually a git repository? --------------------------------------
if [ ! -d .git ]; then
  say "ERROR: no .git here — wrong folder. Nothing sent."
  exit 1
fi

# --- Is there anything to send? ----------------------------------------------
# Silence is the normal case: if the news has not moved, the rebuilt files are
# byte-identical and there is genuinely nothing to publish.
if [ -z "$(git status --porcelain)" ]; then
  say "No changes — nothing to publish."
  say "---- run end ----"
  exit 0
fi

say "Changed files:"
git status --short >> "$LOG"

# The cache version is what makes installed copies offer the update, so record
# which one is going out. If this does not change, phones keep the old copy.
VERSION=$(grep -o "palio-[a-z0-9]*" sw.js 2>/dev/null | head -1)
say "Cache version going out: ${VERSION:-unknown}"

# --- Send it ------------------------------------------------------------------
git add -A
if ! git commit -m "Automatic news refresh — $(date '+%d %b %Y %H:%M')" >> "$LOG" 2>&1; then
  say "ERROR: commit failed. Nothing sent."
  exit 1
fi

if git push >> "$LOG" 2>&1; then
  say "Published. Live within a minute."
else
  say "ERROR: push refused — usually a sign-in problem. The commit is saved"
  say "       locally and will go out on the next successful run."
  exit 1
fi

say "---- run end ----"
