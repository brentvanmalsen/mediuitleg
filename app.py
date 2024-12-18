from flask import Flask, request, jsonify
import cv2
import numpy as np
import easyocr
import os
from werkzeug.utils import secure_filename


app = Flask(__name__)

# Initialize EasyOCR
reader = easyocr.Reader(['en'], gpu=True)

# Function to correct image rotation
def correct_rotation(img):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150, apertureSize=3)
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, 100, minLineLength=100, maxLineGap=10)
    angles = [np.arctan2(y2 - y1, x2 - x1) * 180 / np.pi for line in lines for x1, y1, x2, y2 in line]
    angle = np.median(angles)
    center = (img.shape[1] // 2, img.shape[0] // 2)
    matrix = cv2.getRotationMatrix2D(center, angle, 1.0)
    return cv2.warpAffine(img, matrix, (img.shape[1], img.shape[0]), flags=cv2.INTER_CUBIC)

@app.route('/process-image', methods=['POST'])
def process_image():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400
    
    # Save and load the uploaded image
    image_file = request.files['image']
    filename = secure_filename(image_file.filename)
    filepath = os.path.join("uploads", filename)
    os.makedirs("uploads", exist_ok=True)
    image_file.save(filepath)

    img = cv2.imread(filepath)
    if img is None:
        return jsonify({"error": "Invalid image file"}), 400

    # Correct image rotation
    img_corrected = correct_rotation(img)
    img_rgb = cv2.cvtColor(img_corrected, cv2.COLOR_BGR2RGB)
    
    # Detect text using EasyOCR
    results = reader.readtext(img_rgb)
    
    # Simplify detected text into a single string
    text_string = " ".join([t[1] for t in results])  # Combine all detected text
    
    return jsonify({
        "detected_text": text_string  # Cleaned and simplified text output
    })

if __name__ == '__main__':
    app.run(debug=True)
