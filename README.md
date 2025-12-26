# Physics Lecture Notes — Automated LaTeX & Anki Pipeline

This repository contains my **physics lecture notes**, maintained using a **custom semantic note–to–LaTeX workflow** designed for long-term academic use.

Notes are written in a lightweight, human-readable format (often derived from handwritten notes), then parsed by a Python compiler that automatically generates:

- structured **LaTeX lecture notes**
- **Anki flashcards** for spaced repetition
- consistent formatting for sections, theorems, exercises, figures, and remarks

The goal is to keep notes **clean, scalable, searchable, and reusable** across multiple courses and semesters while minimizing manual formatting.

---

## ✨ Key Features

- **Semantic labels** instead of raw LaTeX  
  (`TH:`, `LM:`, `EX:`, `NOTE:`, `PRE:`, `POST:`, `FIG #:`)
- Automatic generation of:
  - sections and subsections
  - theorems, lemmas, corollaries
  - exercises and remarks
  - equations and derivations
- **Inline figure integration** from numbered image exports
- **Anki deck export** via `Q:` / `A:` blocks
- Modular LaTeX structure (`main.tex`, `template.tex`, `notes.tex`)
- GitHub ↔ Overleaf synchronization for automatic PDF updates

---

## 📂 Repository Structure

```
.
├── mainQM2.tex          # Main LaTeX document
├── template.tex         # Styling, environments, macros
├── physics_compiler.py  # Python note compiler
├── notes/               # Raw plaintext / Markdown notes
├── out/                 # Auto-generated LaTeX bodies
├── figures/             # Numbered figure images (1.png, 2.png, ...)
├── anki/                # Exported Anki decks
└── README.md
```

---

## 🧠 Workflow Overview

1. Write notes using semantic labels (plain text / Markdown)
2. Export handwritten figures as numbered images (`1.png`, `2.png`, …)
3. Run the compiler:
   ```bash
   python physics_compiler.py notes.md out/
   ```
4. Commit and push:
   ```bash
   git add out/notes.tex figures/
   git commit -m "Update lecture notes"
   git push
   ```
5. Overleaf automatically updates and recompiles the PDF

---

## 🎯 Design Philosophy

- **Write once, render many times** (PDF, Anki, future formats)
- Separate **content** from **presentation**
- Favor explicit structure over heuristic parsing
- Scale naturally from coursework to research-level notes

This system is intended to grow across multiple physics courses and may evolve into a broader personal knowledge and research note system.

---

## 📜 License

- **Source code** (Python scripts and tooling):  
  Licensed under the **MIT License**

- **Lecture notes, explanations, and figures**:  
  Licensed under **Creative Commons Attribution–NonCommercial–ShareAlike 4.0 (CC BY-NC-SA 4.0)**

See `LICENSE` and `LICENSE-NOTES.md` for details.

---

## 🔖 Status

This repository is actively maintained and will continue to expand with future courses and lecture material.
