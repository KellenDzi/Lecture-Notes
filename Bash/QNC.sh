#!/bin/bash
set -e  # Exit immediately if any command fails

# =================================================
# CONFIG — YOUR ACTUAL PATHS
# =================================================

REPO_ROOT="/Users/dzi/Documents/Lecture Notes"

# Markdown (OCR) input directory
MD_DIR="$REPO_ROOT/Markdown"

# Python compiler
COMPILER_SCRIPT="$REPO_ROOT/Compiler/Notes.py"

# Output directory for notes.tex
OUT_DIR="$REPO_ROOT/Spring 2026/PHYS 6347 Quantum Network and Communication/notes"

# Commit message prefix
COMMIT_PREFIX="Update lecture notes"

# =================================================
# INPUT CHECK
# =================================================

if [ "$#" -ne 1 ]; then
  echo "Usage: ./compile_and_push.sh <markdown_file>"
  echo "Example: ./compile_and_push.sh Lecture_5.md"
  exit 1
fi

MD_FILE="$1"
INPUT_MD="$MD_DIR/$MD_FILE"

if [ ! -f "$INPUT_MD" ]; then
  echo "Error: Markdown file not found:"
  echo "  $INPUT_MD"
  exit 1
fi

# =================================================
# STEP 0 — Go to repo root
# =================================================

cd "$REPO_ROOT"

# =================================================
# STEP 1 — Pull latest changes
# =================================================

echo "🔄 Pulling latest changes from GitHub..."
git pull

# =================================================
# STEP 2 — Compile notes
# =================================================

echo "🛠  Compiling OCR markdown:"
echo "   $INPUT_MD"
echo "➡️  Output directory:"
echo "   $OUT_DIR"

python3 "$COMPILER_SCRIPT" "$INPUT_MD" "$OUT_DIR"

# =================================================
# STEP 3 — Stage generated output
# =================================================

echo "➕ Staging generated notes..."
git add "$OUT_DIR"

# =================================================
# STEP 4 — Commit
# =================================================

TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
COMMIT_MSG="$COMMIT_PREFIX ($TIMESTAMP)"

echo "📝 Committing changes..."
git commit -m "$COMMIT_MSG" || {
  echo "⚠️  Nothing new to commit."
}

# =================================================
# STEP 5 — Push to GitHub
# =================================================

echo "🚀 Pushing to remote repository..."
git push

echo "✅ Done. Notes compiled and synced to GitHub."