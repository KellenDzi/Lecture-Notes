#!/bin/bash
set -e

# =================================================
# ROOT
# =================================================

REPO_ROOT="/Users/dzi/Documents/Lecture Notes"
BASH_DIR="$REPO_ROOT/Bash"
MD_DIR="$REPO_ROOT/Markdown"
COMPILER="$REPO_ROOT/Compiler/Notes.py"

cd "$REPO_ROOT"

# =================================================
# USER INPUT
# =================================================

echo "📚 Course setup"

read -p "📆 Enter term name (e.g. Spring 2026): " TERM
read -p "📘 Enter course name (e.g. Quantum Mechanics II): " COURSE_NAME
read -p "📘 Enter course code (or 'none'): " COURSE_CODE
read -p "🔤 Enter course abbreviation (e.g. QM2): " ABBR

# Normalize course code
if [[ -z "$COURSE_CODE" || "$COURSE_CODE" =~ ^(none|NONE|None)$ ]]; then
  COURSE_CODE=""
  COURSE_PREFIX=""
else
  COURSE_PREFIX="$COURSE_CODE "
fi

# =================================================
# DIRECTORY SETUP
# =================================================

TERM_DIR="$REPO_ROOT/$TERM"
COURSE_DIR="$TERM_DIR/${COURSE_PREFIX}${COURSE_NAME}"
NOTES_DIR="$COURSE_DIR/notes"
FIG_DIR="$COURSE_DIR/figures"

mkdir -p "$NOTES_DIR" "$FIG_DIR" "$BASH_DIR"

# =================================================
# MAIN TEX FILE
# =================================================

MAIN_TEX="$COURSE_DIR/main${ABBR}.tex"

if [ ! -f "$MAIN_TEX" ]; then
  cat <<EOF > "$MAIN_TEX"
\\documentclass[10pt,twocolumn]{article}

\\input{../Template/template}
\\input{notes/meta}

% ---------- Course metadata ----------
\\newcommand{\\CourseName}{$COURSE_NAME}
\\newcommand{\\CourseCode}{$COURSE_CODE}
\\newcommand{\\Term}{$TERM}

% Defaults overridden by meta.tex
\\newcommand{\\LectureTitle}{}
\\newcommand{\\LectureDate}{}

\\title{
  \\ifx\\CourseCode\\empty
    \\CourseName \\\\[0.4ex]
  \\else
    \\CourseCode: \\CourseName \\\\[0.4ex]
  \\fi
  \\large \\LectureTitle \\\\[0.4ex]
  \\normalsize \\Term
}

\\author{
  \\ProfessorName \\\\
  \\StudentName \\\\
  \\Department \\\\
  \\University
}

\\date{\\LectureDate}

\\begin{document}

\\twocolumn[
\\maketitle

\\begin{center}
\\small
\\colorsquare{ExerciseBlue}\\; Exercises \\quad
\\colorsquare{LogicGreen}\\; Theorems, Lemmas, Corollaries \\quad
\\colorsquare{violet}\\; Pre-Lecture \\quad
\\colorsquare{black}\\; Post-Lecture \\quad
\\colorsquare{red}\\; Remarks
\\end{center}

\\vspace{0.75em}
]

\\begingroup
\\hypersetup{linkcolor=black}
\\let\\clearpage\\relax
\\tableofcontents
\\endgroup

\\input{notes/notes}

\\end{document}
EOF
fi

# =================================================
# COURSE-SPECIFIC BASH SCRIPT
# =================================================

COURSE_SCRIPT="$BASH_DIR/$ABBR.sh"

cat <<EOF > "$COURSE_SCRIPT"
#!/bin/bash
set -e

REPO_ROOT="$REPO_ROOT"
MD_DIR="\$REPO_ROOT/Markdown"
OUT_DIR="$NOTES_DIR"
COMPILER="$COMPILER"

if [ "\$#" -ne 1 ]; then
  echo "Usage: ./$ABBR.sh <markdown_file>"
  exit 1
fi

MD_FILE="\$MD_DIR/\$1"

cd "\$REPO_ROOT"

git pull

python3 "\$COMPILER" "\$MD_FILE" "\$OUT_DIR"

git add "\$OUT_DIR"
git commit -m "Update $COURSE_NAME lecture notes" || echo "No changes to commit"
git push

echo "✅ Done"
EOF

chmod +x "$COURSE_SCRIPT"

# =================================================
# GIT SYNC
# =================================================

git add "$COURSE_DIR" "$COURSE_SCRIPT"
git commit -m "Initialize $COURSE_NAME course structure" || true
git push

echo "🎉 Course initialized successfully!"
echo "▶ Use: $ABBR.sh <markdown_file>"