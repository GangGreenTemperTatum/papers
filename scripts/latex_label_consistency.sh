#!/bin/bash
# A robust script to find \section or \subsection commands missing a \label.
# v4: Allows the \label to be on the SAME line as the section command OR on the next line.

# Find the directory where the script itself is located.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Assume the project root is one level up from the script's directory.
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
PAPER_DIR="$PROJECT_ROOT/paper"

# Check if the paper directory actually exists.
if [ ! -d "$PAPER_DIR" ]; then
  echo "Error: Could not find the paper directory at '$PAPER_DIR'"
  exit 1
fi

echo "🔍 Checking for missing labels in '$PAPER_DIR'..."
echo "----------------------------------------------------"

found_issues=0

while IFS= read -r -d $'\0' file; do
  # awk logic updated to check both the section line and the next line for a label.
  awk '
    # This condition now checks for a section that is missing a label in BOTH possible locations.
    (prev_line ~ /\\(sub)?section\{/) && (prev_line !~ /\\label\{/) && ($0 !~ /^[[:space:]]*\\label\{/) {
        printf("\n[ISSUE FOUND]\n");
        printf("  File: %s\n", FILENAME);
        printf("  Line %d: %s\n", FNR-1, prev_line);
        printf("  -> This section is missing a \\label on the same line OR the next line.\n");
        exit 1;
    }
    {
      # Always store the current line for the next iteration.
      prev_line = $0;
    }
  ' "$file"

  if [ $? -ne 0 ]; then
    found_issues=1
  fi
done < <(find "$PAPER_DIR" -name "*.tex" -print0)

# --- Final Report ---
echo "----------------------------------------------------"
if [ "$found_issues" -eq 0 ]; then
  echo "Success! All sections have a label in a valid position."
else
  echo "⚠️ Issues were found. Please review the output above."
fi
