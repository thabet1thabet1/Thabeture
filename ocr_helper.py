#!/usr/bin/env python3
"""
Simple OCR helper script for Flutter app
Usage: python3 ocr_helper.py <image_path>
"""

import sys
import os
from PIL import Image
import pytesseract

def extract_text_from_image(image_path):
    """Extract text from image using Tesseract OCR"""
    try:
        # Check if image file exists
        if not os.path.exists(image_path):
            print(f"ERROR: Image file not found: {image_path}")
            return None
        
        # Open and process the image
        image = Image.open(image_path)
        
        # Extract text using Tesseract
        text = pytesseract.image_to_string(image)
        
        # Clean up the text
        text = text.strip()
        
        if text:
            print(text)
            return text
        else:
            print("ERROR: No text found in image")
            return None
            
    except Exception as e:
        print(f"ERROR: {str(e)}")
        return None

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 ocr_helper.py <image_path>")
        sys.exit(1)
    
    image_path = sys.argv[1]
    extract_text_from_image(image_path)