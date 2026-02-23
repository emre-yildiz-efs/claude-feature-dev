#!/bin/bash
# Auto-lint TypeScript/React files after Claude edits them

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')

# Only process TS/TSX/JSX files
if [[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.tsx && "$FILE_PATH" != *.jsx ]]; then
  exit 0
fi

if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Run eslint with auto-fix
ESLINT_OUTPUT=$(npx eslint --fix "$FILE_PATH" 2>&1)
ESLINT_EXIT=$?

# Run prettier
PRETTIER_OUTPUT=$(npx prettier --write "$FILE_PATH" 2>&1)

if [[ $ESLINT_EXIT -ne 0 ]]; then
  echo "ESLint found issues in $FILE_PATH:" >&2
  echo "$ESLINT_OUTPUT" >&2
  exit 2
fi

exit 0
