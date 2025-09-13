#!/bin/bash

echo "🚀 Starting Screenshot OCR Service..."

# Kill any existing OCR service
pkill -f ocr_service.py 2>/dev/null

# Start the OCR service
python3 ~/ocr_service.py &

# Get the process ID
OCR_PID=$!

echo "✅ OCR Service started with PID: $OCR_PID"
echo "📷 Ready to process screenshots!"
echo ""
echo "💡 Usage:"
echo "1. Use your Flutter menu bar app to take screenshots"
echo "2. Text will be automatically extracted and copied"
echo "3. Press Ctrl+C to stop the OCR service"
echo ""

# Wait for the service to finish
wait $OCR_PID