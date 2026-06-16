#!/bin/bash
# This script checks that every .tex file ends with a newline character.

# --- Configuration ---

# Find the directory where the script itself is located.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Assume the project root is one level up from the script's directory.
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
TARGET_DIR="$PROJECT_ROOT/paper"

# --- Script Body ---

# Check if the target directory actually exists.
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Could not find the paper directory at '$TARGET_DIR'"
  exit 1
fi

echo "🔍 Checking for missing final newlines in '$TARGET_DIR/'..."
echo "----------------------------------------------------"

found_issues=0

# Use the robust `while read` loop with process substitution
while IFS= read -r -d $'\0' file; do
  # This check is for non-empty files only.
  if [ -s "$file" ]; then
    # The trick here relies on how command substitution `$(...)` works:
    # it strips all trailing newline characters from the output.
    # So, if the last character of a file IS a newline, `tail` outputs it,
    # but `$(...)` removes it, resulting in an empty string.
    # If the last character is NOT a newline, it is kept.
    if [ "$(tail -c 1 "$file")" != "" ]; then
      echo "[ISSUE FOUND] The file does not end with a newline: $file"
      found_issues=1
    fi
  fi
done < <(find "$TARGET_DIR" -name "*.tex" -print0)

# --- Final Report ---
echo "----------------------------------------------------"
if [ "$found_issues" -eq 0 ]; then
  echo "Success! All .tex files end with a newline."
else
  echo "⚠️ Issues were found. Please review the files listed above."
  echo "   (You can fix this by opening the file, adding a new line at the end, and saving.)"
fi
