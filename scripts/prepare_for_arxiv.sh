#!/bin/bash

# prepare_for_arxiv.sh
# Comprehensive script to prepare arXiv submission package:
# 1. Copy necessary files from paper directory
# 2. Compile the document to generate required files
# 3. Create the final archive for submission

set -e  # Exit on error

PAPER_DIR="paper"
ARXIV_DIR="arxiv_submission"
TEMP_DIR="arxiv_submission_temp"
ARCHIVE_NAME="arxiv_submission.tar.gz"

echo "===== PREPARING ARXIV SUBMISSION PACKAGE ====="

# Step 0: Clean the existing arxiv_submission directory
echo "Cleaning target directory..."
mkdir -p "$ARXIV_DIR"
rm -rf "$ARXIV_DIR"/*

# Step 1: Copy necessary files from paper directory
echo "Copying essential files from $PAPER_DIR to $ARXIV_DIR..."
cp "$PAPER_DIR/main.tex" "$ARXIV_DIR/"
cp "$PAPER_DIR/bibliography.bib" "$ARXIV_DIR/"

# Copy section files
echo "Copying section files..."
mkdir -p "$ARXIV_DIR/section"
cp "$PAPER_DIR/section"/*.tex "$ARXIV_DIR/section/"

# Copy optional appendix files
if [ -d "$PAPER_DIR/appx" ]; then
    echo "Copying appendix files..."
    mkdir -p "$ARXIV_DIR/appx"
    cp "$PAPER_DIR/appx"/*.tex "$ARXIV_DIR/appx/" 2>/dev/null || true
fi

# Copy optional data files
if [ -d "$PAPER_DIR/data" ]; then
    echo "Copying data files..."
    mkdir -p "$ARXIV_DIR/data"
    cp "$PAPER_DIR/data"/*.tex "$ARXIV_DIR/data/" 2>/dev/null || true
fi

# Check and copy figures directory - only copy figures referenced in the paper
echo "Copying figures..."
if [ -d "$PAPER_DIR/figures" ]; then
    mkdir -p "$ARXIV_DIR/figures"
    cp "$PAPER_DIR/figures"/*.* "$ARXIV_DIR/figures/" 2>/dev/null || echo "No figures found"
fi

# Step 2: Compile the document
echo "Compiling document for arXiv submission..."
cd "$ARXIV_DIR"

# Pull the latest TexLive image if needed
docker pull registry.gitlab.com/islandoftex/images/texlive:latest

# LaTeX compilation sequence
docker run --rm -v "$(pwd)":/workdir registry.gitlab.com/islandoftex/images/texlive:latest /bin/sh -c "cd /workdir && pdflatex main.tex && bibtex main && pdflatex main.tex && pdflatex main.tex"

# Check if .bbl files were created
if [ -f "main.bbl" ]; then
  echo "main.bbl created successfully"
else
  echo "Failed to create main.bbl"
  exit 1
fi

cd ..

# Step 3: Create the submission archive
echo "Creating arXiv submission archive..."

# Create temporary directory for submission
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Copy ONLY essential files for arxiv submission
cp "$ARXIV_DIR/main.tex" "$TEMP_DIR/"
cp "$ARXIV_DIR/main.bbl" "$TEMP_DIR/"

# Copy required and optional directories
cp -r "$ARXIV_DIR/section" "$TEMP_DIR/"

if [ -d "$ARXIV_DIR/appx" ]; then
    cp -r "$ARXIV_DIR/appx" "$TEMP_DIR/"
fi

if [ -d "$ARXIV_DIR/data" ]; then
    cp -r "$ARXIV_DIR/data" "$TEMP_DIR/"
fi

# Copy figures if they exist
if [ -d "$ARXIV_DIR/figures" ]; then
    cp -r "$ARXIV_DIR/figures" "$TEMP_DIR/"
fi

# Create the tar.gz file
echo "Creating archive: $ARCHIVE_NAME"
tar -czf "$ARCHIVE_NAME" -C "$TEMP_DIR" .

# Display archive contents for verification
echo "Archive contents:"
tar -tvf "$ARCHIVE_NAME" | sort

# Display archive size
echo "Archive size: $(du -h "$ARCHIVE_NAME" | cut -f1)"

# Clean up
rm -rf "$TEMP_DIR"

# Check if archive was created successfully
if [ -f "$ARCHIVE_NAME" ]; then
  echo "Archive created successfully: $ARCHIVE_NAME"
  echo "File size: $(du -h "$ARCHIVE_NAME" | cut -f1)"
  echo ""
  echo "Instructions for submission:"
  echo "1. Go to arxiv.org and start a new submission"
  echo "2. Upload $ARCHIVE_NAME when prompted for files"
  echo "3. Make sure to select the appropriate arXiv category for your paper"
  echo ""
  echo "Note: You may need to find an endorser if this is your first submission"
else
  echo "Failed to create archive."
  exit 1
fi

echo "===== ARXIV SUBMISSION PREPARATION COMPLETE ====="
