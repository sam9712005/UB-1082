import os
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import sys
import json
import uuid
import datetime
import numpy as np
import tensorflow as tf
import cv2

from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import inch
from reportlab.lib import colors

# ================= CONFIG =================

CLASS_NAMES = [
    "glioma_tumor",
    "meningioma_tumor",
    "pituitary_tumor",
    "no_tumor"
]

MODEL_VERSION = "BrainTumorClassifier v2.0"

BASE_DIR = os.path.dirname(__file__)
MODEL_PATH = os.path.join(BASE_DIR, "brain_tumor_classifier_model.h5")
REPORTS_DIR = os.path.join(BASE_DIR, "reports")

os.makedirs(REPORTS_DIR, exist_ok=True)

# ================= LOAD MODEL =================

try:
    model = tf.keras.models.load_model(MODEL_PATH)
except Exception:
    print(json.dumps({
        "classification": "Model Load Error",
        "confidence_score": "0%",
        "severity": "Unknown",
        "probabilities": {},
        "report_file": None
    }))
    sys.exit(0)


# ================= IMAGE PREPROCESS =================

def preprocess_image(image_path):
    img = cv2.imread(image_path)

    if img is None:
        raise ValueError("Invalid image")

    img = cv2.resize(img, (224, 224))
    img = img / 255.0
    img = np.expand_dims(img, axis=0)
    return img


# ================= SEVERITY LOGIC =================

def determine_severity(label, confidence):
    if label == "no_tumor":
        return "Low"

    if confidence > 0.90:
        return "High"
    elif confidence > 0.70:
        return "Moderate"
    else:
        return "Indeterminate"


# ================= PDF GENERATION =================

def generate_report(data):
    report_id = f"report_{uuid.uuid4().hex}.pdf"
    report_path = os.path.join(REPORTS_DIR, report_id)

    doc = SimpleDocTemplate(report_path, pagesize=A4)
    elements = []

    title_style = ParagraphStyle(name="Title", fontSize=18, textColor=colors.darkblue)
    section_style = ParagraphStyle(name="Section", fontSize=14)
    normal_style = ParagraphStyle(name="Normal", fontSize=11)

    # Header
    elements.append(Paragraph("AI-Assisted Brain MRI Diagnostic Report", title_style))
    elements.append(Spacer(1, 0.3 * inch))

    metadata = [
        ["Report ID", uuid.uuid4().hex[:8]],
        ["Date", str(datetime.datetime.now())],
        ["Model Version", MODEL_VERSION],
        ["Scan Type", "Brain MRI"]
    ]

    table = Table(metadata, colWidths=[150, 350])
    table.setStyle(TableStyle([
        ('GRID', (0, 0), (-1, -1), 0.5, colors.grey)
    ]))

    elements.append(table)
    elements.append(Spacer(1, 0.3 * inch))

    # Diagnostic Summary
    elements.append(Paragraph("1. Diagnostic Summary", section_style))
    elements.append(Spacer(1, 0.1 * inch))

    elements.append(Paragraph(f"<b>Primary Classification:</b> {data['classification']}", normal_style))
    elements.append(Paragraph(f"<b>Model Confidence:</b> {data['confidence_score']}", normal_style))
    elements.append(Paragraph(f"<b>AI Risk Stratification:</b> {data['severity']}", normal_style))
    elements.append(Spacer(1, 0.3 * inch))

    # Probability Distribution
    elements.append(Paragraph("2. Probability Distribution", section_style))
    elements.append(Spacer(1, 0.1 * inch))

    prob_data = [["Tumor Type", "Probability"]]
    for k, v in data["probabilities"].items():
        prob_data.append([k.replace("_", " "), v])

    prob_table = Table(prob_data, colWidths=[250, 150])
    prob_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.lightgrey),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
        ('ALIGN', (1, 1), (-1, -1), 'RIGHT')
    ]))

    elements.append(prob_table)
    elements.append(Spacer(1, 0.3 * inch))

    # Interpretation
    elements.append(Paragraph("3. Clinical Interpretation", section_style))
    elements.append(Spacer(1, 0.1 * inch))

    if data["classification"] == "no_tumor":
        interpretation = (
            "The AI model does not detect radiological patterns suggestive of intracranial tumor."
        )
        recommendation = (
            "Routine follow-up recommended if symptoms persist."
        )
    else:
        interpretation = (
            f"Imaging features are consistent with {data['classification']}. "
            "Further clinical evaluation recommended."
        )
        recommendation = (
            "Neurologist consultation and contrast-enhanced MRI advised."
        )

    elements.append(Paragraph(interpretation, normal_style))
    elements.append(Spacer(1, 0.2 * inch))
    elements.append(Paragraph("<b>Recommendation:</b>", normal_style))
    elements.append(Paragraph(recommendation, normal_style))
    elements.append(Spacer(1, 0.5 * inch))

    elements.append(Paragraph(
        "⚠ AI-generated report for screening support only. "
        "Not a replacement for professional medical diagnosis.",
        normal_style
    ))

    doc.build(elements)

    return report_id


# ================= MAIN =================

if __name__ == "__main__":

    try:
        image_path = sys.argv[1]

        img = preprocess_image(image_path)
        prediction = model.predict(img, verbose=0)[0]

        class_index = int(np.argmax(prediction))
        confidence_value = float(prediction[class_index])

        classification = CLASS_NAMES[class_index]
        confidence = f"{round(confidence_value * 100, 2)}%"

        probabilities = {
            CLASS_NAMES[i]: f"{round(float(prediction[i]) * 100, 2)}%"
            for i in range(len(CLASS_NAMES))
        }

        severity = determine_severity(classification, confidence_value)

        result = {
            "classification": classification,
            "confidence_score": confidence,
            "severity": severity,
            "probabilities": probabilities
        }

        report_file = generate_report(result)
        result["report_file"] = report_file

        print(json.dumps(result))

    except Exception:
        print(json.dumps({
            "classification": "Processing Error",
            "confidence_score": "0%",
            "severity": "Unknown",
            "probabilities": {},
            "report_file": None
        }))