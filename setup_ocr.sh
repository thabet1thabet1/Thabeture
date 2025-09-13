#!/bin/bash

echo "🚀 Setting up OCR for Screenshot App..."

# Check if Tesseract is installed
if ! command -v tesseract &> /dev/null; then
    echo "❌ Tesseract not found. Installing via Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    brew install tesseract
fi

# Check if Python packages are installed
echo "📦 Checking Python packages..."
python3 -c "import PIL, pytesseract" 2>/dev/null || {
    echo "📦 Installing Python packages..."
    pip3 install pillow pytesseract
}

# Copy OCR helper to home directory
echo "📋 Setting up OCR helper..."
cp ocr_helper.py ~/ocr_helper.py
chmod +x ~/ocr_helper.py

# Create a simple OCR service script
cat > ~/ocr_service.py << 'EOF'
#!/usr/bin/env python3
"""
OCR Service for Screenshot App
Monitors for screenshot files and processes them automatically
"""

import os
import sys
import time
import subprocess
from pathlib import Path
from PIL import Image
import pytesseract

def process_screenshot(image_path):
    """Process a screenshot and return extracted text"""
    try:
        if not os.path.exists(image_path):
            return None
        
        # Extract text using Tesseract
        image = Image.open(image_path)
        text = pytesseract.image_to_string(image)
        text = text.strip()
        
        if text:
            # Copy to clipboard using pbcopy
            process = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE)
            process.communicate(text.encode('utf-8'))
            
            print(f"✅ Extracted and copied {len(text)} characters to clipboard")
            print(f"Text: {text[:100]}..." if len(text) > 100 else f"Text: {text}")
            return text
        else:
            print("❌ No text found in image")
            return None
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def monitor_screenshots():
    """Monitor screenshot directory for new files"""
    screenshot_dir = Path.home() / "Library/Containers/com.example.thabeture/Data/Library/Caches/screenshots"
    
    if not screenshot_dir.exists():
        print(f"❌ Screenshot directory not found: {screenshot_dir}")
        return
    
    print(f"👀 Monitoring: {screenshot_dir}")
    
    processed_files = set()
    
    while True:
        try:
            # Check for new screenshot files
            for file_path in screenshot_dir.glob("screenshot_*.png"):
                if file_path.name not in processed_files:
                    print(f"📸 New screenshot: {file_path.name}")
                    process_screenshot(str(file_path))
                    processed_files.add(file_path.name)
            
            time.sleep(1)  # Check every second
            
        except KeyboardInterrupt:
            print("\n👋 OCR service stopped")
            break
        except Exception as e:
            print(f"❌ Monitor error: {e}")
            time.sleep(5)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Process single file
        process_screenshot(sys.argv[1])
    else:
        # Monitor mode
        monitor_screenshots()
EOF

chmod +x ~/ocr_service.py

echo "✅ OCR setup complete!"
echo ""
echo "🎯 To use:"
echo "1. Run the OCR service: python3 ~/ocr_service.py"
echo "2. Take screenshots with your Flutter app"
echo "3. Text will be automatically extracted and copied to clipboard!"
echo ""
echo "📋 Or process individual files: python3 ~/ocr_helper.py <image_path>"