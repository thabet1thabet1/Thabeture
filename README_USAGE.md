# 📷 Screenshot OCR App - Usage Guide

## 🚀 Quick Start

### 1. Start OCR Service (One Command)
```bash
python3 ~/ocr_service.py &
```

### 2. Use the App
- Click the 📷 camera icon in your menu bar
- Select "Take Area Screenshot"
- Drag to select text area
- Text automatically copied to clipboard!

## 🔧 Easy Setup

### Make it even easier - create an alias:
```bash
echo 'alias start-ocr="python3 ~/ocr_service.py &"' >> ~/.zshrc
source ~/.zshrc
```

Now you can just run:
```bash
start-ocr
```

## 📋 How It Works

1. **OCR Service**: Monitors screenshot folder and processes images
2. **Flutter App**: Captures screenshots via menu bar
3. **Automatic**: When OCR service detects new screenshot → extracts text → copies to clipboard

## ✅ Status Check

- **OCR Running**: App shows "OCR service processing..." 
- **OCR Not Running**: App shows setup instructions

## 🛠 Troubleshooting

### OCR Service Not Working?
```bash
# Check if running
pgrep -f ocr_service.py

# Restart if needed
pkill -f ocr_service.py
python3 ~/ocr_service.py &
```

### No Text Extracted?
- Make sure screenshot contains clear text
- Check OCR service is running
- Try with high-contrast text

## 🎯 Perfect Workflow

1. **Once per session**: `python3 ~/ocr_service.py &`
2. **Take screenshots**: Use menu bar app
3. **Get text**: Automatically copied to clipboard
4. **Paste anywhere**: Cmd+V

Your Screenshot OCR app is ready! 🚀