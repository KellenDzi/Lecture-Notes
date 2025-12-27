#!/bin/bash
set -e

# =================================================
# CONFIG
# =================================================

REPO_ROOT="/Users/dzi/Documents/Lecture Notes"
BASH_DIR="$REPO_ROOT/Bash"

cd "$REPO_ROOT"

echo
echo "⚠️  UNDO COURSE SETUP"
echo "This will REMOVE a course folder and its bash script."
echo

# =================================================
# USER INPUT
# =================================================

read -p "📆 Enter term name (e.g. Spring 2026): " TERM
read -p "📘 Enter course name (e.g. Quantum Mechanics II): " COURSE_NAME
read -p "📘 Enter course code (or 'none'): " COURSE_CODE
read -p "🔤 Enter course abbreviation (e.g. QM2): " ABBR

# -------------------------------------------------
# Normalize course code (FIXES 'none' BUG)
# -------------------------------------------------

COURSE_CODE=$(echo "$COURSE_CODE" | xargs)  # trim whitespace

if [[ -z "$COURSE_CODE" || "$COURSE_CODE" =~ ^[Nn][Oo][Nn][Ee]$ ]]; then
  COURSE_PREFIX=""
else
  COURSE_PREFIX="$COURSE_CODE "
fi

COURSE_DIR="$REPO_ROOT/$TERM/${COURSE_PREFIX}${COURSE_NAME}"
COURSE_SCRIPT="$BASH_DIR/$ABBR.sh"

echo
echo "🧾 The following will be removed:"
echo "  📁 Course directory: $COURSE_DIR"
echo "  📜 Bash script:      $COURSE_SCRIPT"
echo

read -p "❓ Proceed with deletion? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "❌ Aborted."
  exit 1
fi

# =================================================
# DELETE FILES
# =================================================

if [ -d "$COURSE_DIR" ]; then
  echo "🗑 Removing course directory..."
  rm -rf "$COURSE_DIR"
else
  echo "⚠️ Course directory not found."
fi

if [ -f "$COURSE_SCRIPT" ]; then
  echo "🗑 Removing bash script..."
  rm -f "$COURSE_SCRIPT"
else
  echo "⚠️ Bash script not found."
fi

# =================================================
# GIT HANDLING (ROBUST & SAFE)
# =================================================

echo
read -p "🔁 Undo last git commit if it created this course? (yes/no): " UNDO_GIT

if [[ "$UNDO_GIT" == "yes" ]]; then
  echo "📦 Stashing local changes..."
  git stash push -u -m "undo-course-temp" || true

  echo "🔄 Syncing with remote..."
  git pull --rebase || {
    echo "❌ Git pull failed — resolve conflicts manually."
    exit 1
  }

  echo "↩️ Reverting last commit..."
  git reset --hard HEAD~1

  echo "📦 Restoring stashed changes..."
  git stash pop || true

else
  echo "📌 Keeping git history; committing deletions."
  git add -A
  git commit -m "Remove ${COURSE_NAME} course setup" || true
fi

echo "🚀 Pushing changes..."
git push || {
  echo "⚠️ Push failed — run 'git pull --rebase' and retry."
}

echo
echo "✅ Undo complete."