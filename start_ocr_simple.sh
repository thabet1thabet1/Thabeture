#!/bin/bash
cd ~
python3 ocr_service.py &
echo $! > /tmp/ocr_service.pid