#!/bin/bash
# Auto-lint Python files after Claude edits them

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')

# Only process Python files
if [[ "$FILE_PATH" != *.py ]]; then
  exit 0
fi

# Check if file exists
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Run ruff check with auto-fix
RUFF_OUTPUT=$(ruff check --fix "$FILE_PATH" 2>&1)
RUFF_EXIT=$?

# Run black formatting
BLACK_OUTPUT=$(black --quiet "$FILE_PATH" 2>&1)
BLACK_EXIT=$?

# Report issues back to Claude
if [[ $RUFF_EXIT -ne 0 ]]; then
  echo "Ruff found issues in $FILE_PATH:" >&2
  echo "$RUFF_OUTPUT" >&2
  exit 2
fi

exit 0
