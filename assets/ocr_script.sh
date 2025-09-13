#!/bin/bash

# OCR Script for Flutter App
# This script runs Tesseract OCR on an image file

IMAGE_PATH="$1"

if [ -z "$IMAGE_PATH" ]; then
    echo "ERROR: No image path provided"
    exit 1
fi

if [ ! -f "$IMAGE_PATH" ]; then
    echo "ERROR: Image file not found: $IMAGE_PATH"
    exit 1
fi

# Try different Tesseract paths
TESSERACT_PATHS=(
    "/opt/homebrew/bin/tesseract"
    "/usr/local/bin/tesseract"
    "/usr/bin/tesseract"
    "tesseract"
)

TESSERACT_CMD=""
for path in "${TESSERACT_PATHS[@]}"; do
    if command -v "$path" >/dev/null 2>&1; then
        TESSERACT_CMD="$path"
        break
    fi
done

if [ -z "$TESSERACT_CMD" ]; then
    echo "ERROR: Tesseract not found in any common locations"
    exit 1
fi

# Run Tesseract OCR
"$TESSERACT_CMD" "$IMAGE_PATH" stdout 2>/dev/null