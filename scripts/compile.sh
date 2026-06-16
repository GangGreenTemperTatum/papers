#!/bin/bash

# Change to the project root directory
cd "$(dirname "$0")/.."

# Pull the images
docker pull registry.gitlab.com/islandoftex/images/texlive:latest
docker pull pandoc/core:latest

# Create build directory if it doesn't exist
mkdir -p build

# Full LaTeX compilation sequence for PDF
docker run --rm -v "$(pwd)/paper:/workdir" registry.gitlab.com/islandoftex/images/texlive:latest /bin/sh -c "pdflatex main.tex && bibtex main && pdflatex main.tex && pdflatex main.tex"
mv paper/main.aux paper/main.log paper/main.out paper/main.bbl paper/main.blg build/ 2>/dev/null || true

# Convert TEX to DOCX directly
docker run --rm -v "$(pwd)/paper:/data" pandoc/core:latest \
    --from latex \
    --to docx \
    /data/main.tex \
    -o /data/paper.docx
