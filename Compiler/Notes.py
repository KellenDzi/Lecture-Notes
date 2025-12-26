import re
from pathlib import Path
from typing import List, Tuple, Optional

# ============================================================
# Regex for lecture metadata and block labels
# ============================================================

# Lecture ID: F25-L5 or SP26-L12
LECTURE_ID_RE = re.compile(r"^(SP|F)\d{2}-L\d+$")

# Structural labels (non-figure)
LABEL_RE = re.compile(
    r"^(PRE|POST|TH|LM|CO|EX|NOTE|S|SS|E|R|Q|A):\s*(.*)$"
)

# Figure label: FIG 1:
FIG_RE = re.compile(r"^FIG\s+(\d+):\s*(.*)$")

# ============================================================
# Utilities
# ============================================================

def split_blocks(text: str):
    """
    Split raw notes into (lecture_id, blocks).

    blocks is a list of tuples:
      (label, fig_number, content)
    where fig_number is None except for FIG blocks.
    """
    lines = text.splitlines()
    blocks = []

    lecture_id: Optional[str] = None
    current_label: Optional[str] = None
    current_fig_number: Optional[str] = None
    current_content: List[str] = []

    def flush():
        nonlocal current_label, current_fig_number, current_content
        if current_label:
            blocks.append(
                (
                    current_label,
                    current_fig_number,
                    "\n".join(current_content).strip()
                )
            )
            current_label = None
            current_fig_number = None
            current_content = []

    for line in lines:
        line = line.rstrip()

        # Detect lecture ID
        if LECTURE_ID_RE.match(line):
            lecture_id = line
            continue

        # Detect FIG n:
        fig_match = FIG_RE.match(line)
        if fig_match:
            flush()
            current_label = "FIG"
            current_fig_number = fig_match.group(1)
            rest = fig_match.group(2)
            current_content = [rest] if rest else []
            continue

        # Detect other labeled blocks
        m = LABEL_RE.match(line)
        if m:
            flush()
            current_label = m.group(1)
            current_fig_number = None
            rest = m.group(2)
            current_content = [rest] if rest else []
        else:
            if current_label:
                current_content.append(line)

    flush()
    return lecture_id, blocks

# ============================================================
# LaTeX emitter
# ============================================================

def emit_latex(blocks, lecture_id: Optional[str]) -> str:
    """
    Convert parsed blocks into LaTeX (notes.tex body).
    """
    out: List[str] = []

    for label, fig_number, content in blocks:

        if label == "S":
            out.append(f"\\section{{{content}}}\n")

        elif label == "SS":
            out.append(f"\\subsection{{{content}}}\n")

        elif label == "PRE":
            out.append(f"\\begin{{presection}}{{{content}}}\n")

        elif label == "POST":
            out.append(f"\\begin{{postsection}}{{{content}}}\n")

        elif label == "TH":
            out.append("\\begin{theorem}\n")
            out.append(content + "\n")
            out.append("\\end{theorem}\n")

        elif label == "LM":
            out.append("\\begin{lemma}\n")
            out.append(content + "\n")
            out.append("\\end{lemma}\n")

        elif label == "CO":
            out.append("\\begin{corollary}\n")
            out.append(content + "\n")
            out.append("\\end{corollary}\n")

        elif label == "EX":
            out.append("\\begin{exercise}\n")
            out.append(content + "\n")
            out.append("\\end{exercise}\n")

        elif label == "NOTE":
            out.append("\\begin{remarkbar}\n")
            out.append(content + "\n")
            out.append("\\end{remarkbar}\n")

        elif label == "E":
            out.append("\\begin{equation}\n")
            out.append(content + "\n")
            out.append("\\end{equation}\n")

        elif label == "R":
            out.append("\\begin{derivation}\n")
            out.append(content + "\n")
            out.append("\\end{derivation}\n")

        elif label == "FIG":
            # Expect figures/#
            fig_stem = fig_number
            fig_dir = Path("figures")

            # Supported formats
            fig_path = None
            for ext in (".png", ".pdf", ".svg"):
                candidate = fig_dir / f"{fig_stem}{ext}"
                if candidate.exists():
                    fig_path = candidate
                    break

            if fig_path is None:
                raise FileNotFoundError(
                    f"Missing figure file: figures/{fig_stem}.(png|pdf|svg)"
                )

            fig_label = f"fig:{lecture_id}-{fig_stem}" if lecture_id else f"fig:{fig_stem}"

            out.append("\\begin{center}\n")
            out.append(
                f"\\includegraphics[width=0.6\\linewidth]{{{fig_path.as_posix()}}}\n"
            )
            out.append(
                f"\\captionof{{figure}}{{{content}}}\n"
            )
            out.append(
                f"\\label{{{fig_label}}}\n"
            )
            out.append("\\end{center}\n")

        # Q/A handled separately

    return "\n".join(out)

# ============================================================
# Anki emitter
# ============================================================

def emit_anki(blocks) -> List[Tuple[str, str]]:
    """
    Extract (question, answer) pairs for Anki.
    """
    cards: List[Tuple[str, str]] = []
    q = None

    for label, _, content in blocks:
        if label == "Q":
            q = content
        elif label == "A" and q is not None:
            cards.append((q, content))
            q = None

    return cards

# ============================================================
# Main compile routine
# ============================================================

def compile_notes(input_file: Path, out_dir: Path):
    """
    Compile raw notes into notes.tex and anki.tsv.
    """
    text = input_file.read_text(encoding="utf-8")

    lecture_id, blocks = split_blocks(text)

    latex = emit_latex(blocks, lecture_id)
    anki_cards = emit_anki(blocks)

    out_dir.mkdir(exist_ok=True)

    # Write LaTeX body
    (out_dir / "notes.tex").write_text(latex, encoding="utf-8")

    # Write Anki TSV
    with open(out_dir / "anki.tsv", "w", encoding="utf-8") as f:
        for q, a in anki_cards:
            f.write(f"{q}\t{a}\n")

    if lecture_id:
        print(f"Compiled lecture {lecture_id}")
    else:
        print("Warning: no lecture ID found")

# ============================================================
# CLI
# ============================================================

if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print("Usage: python physics_compiler.py input.md out_dir/")
        sys.exit(1)

    compile_notes(Path(sys.argv[1]), Path(sys.argv[2]))