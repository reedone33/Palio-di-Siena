#!/bin/bash
# =============================================================================
# PUBLISH THE PALIO APP TO GITHUB
# =============================================================================
# Double-click this file in Finder and it will send the current contents of
# this folder to your GitHub repository. The live site updates a minute later.
#
# It uses whatever GitHub sign-in is already set up on your Mac. Nothing in
# here asks for, stores, or handles a password or token — that stays between
# you, your Mac's keychain, and GitHub.
#
# FIRST TIME ONLY: see "First-time setup" at the bottom of this file, or the
# same section in readme.html.
# =============================================================================

# Work in the folder this script lives in, wherever that happens to be.
cd "$(dirname "$0")" || exit 1

echo ""
echo "  Palio — publish to GitHub"
echo "  ========================="
echo ""

# --- Is git even installed? --------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
  echo "  git isn't installed on this Mac."
  echo "  Open Terminal and run:  xcode-select --install"
  echo ""
  read -n 1 -s -r -p "  Press any key to close."
  exit 1
fi

# --- Has this folder been connected to a repository yet? ---------------------
if [ ! -d .git ]; then
  echo "  This folder isn't connected to a GitHub repository yet."
  echo ""
  echo "  Run these four lines in Terminal, from this folder, replacing"
  echo "  YOUR-USERNAME and the repository name if you chose a different one:"
  echo ""
  echo "      git init -b main"
  echo "      git remote add origin https://github.com/YOUR-USERNAME/palio.git"
  echo "      git add -A"
  echo "      git commit -m \"First publish\""
  echo "      git push -u origin main"
  echo ""
  echo "  After that, double-clicking this file is all you'll ever need."
  echo ""
  read -n 1 -s -r -p "  Press any key to close."
  exit 1
fi

# --- Anything to send? -------------------------------------------------------
if [ -z "$(git status --porcelain)" ]; then
  echo "  Nothing has changed since the last publish."
  echo ""
  read -n 1 -s -r -p "  Press any key to close."
  exit 0
fi

echo "  These files have changed:"
echo ""
git status --short | sed 's/^/    /'
echo ""

# Show the cache version going out, since that's what makes installed copies
# offer the update.
VERSION=$(grep -o "palio-[a-z0-9]*" sw.js | head -1)
echo "  Cache version in this build:  $VERSION"
echo ""

read -r -p "  Publish these changes? [y/N] " REPLY
echo ""
case "$REPLY" in
  [yY]) ;;
  *) echo "  Cancelled — nothing was sent."; echo ""
     read -n 1 -s -r -p "  Press any key to close."; exit 0 ;;
esac

# --- Send it -----------------------------------------------------------------
git add -A
git commit -m "Update Palio dashboard — $(date '+%d %b %Y %H:%M')" || {
  echo "  Commit failed. Nothing was sent."
  read -n 1 -s -r -p "  Press any key to close."; exit 1
}

echo ""
echo "  Sending to GitHub..."
if git push; then
  echo ""
  echo "  Published. The live site updates within a minute."
  echo "  On any device with the app installed, press 'Check for updates'."
else
  echo ""
  echo "  The push was refused. The usual cause is that this Mac isn't signed"
  echo "  in to GitHub yet — see 'First-time setup' below."
fi

echo ""
read -n 1 -s -r -p "  Press any key to close."

# =============================================================================
# FIRST-TIME SETUP
# =============================================================================
# Your Mac needs to be signed in to GitHub once. Pick whichever suits you:
#
#   EASIEST — GitHub Desktop
#     Install it from desktop.github.com, sign in, and add this folder as a
#     local repository. It stores the sign-in for you, and this script will
#     then work.
#
#   TERMINAL — GitHub CLI
#     brew install gh
#     gh auth login          <- asks you to sign in through your browser
#
#   MANUAL — personal access token
#     GitHub will prompt for a username and password the first time you push.
#     The "password" must be a personal access token, not your account
#     password: github.com -> Settings -> Developer settings -> Personal access
#     tokens. macOS stores it in the keychain afterwards, so you enter it once.
#
# In every case you sign in yourself. This script never sees the credential.
# =============================================================================
