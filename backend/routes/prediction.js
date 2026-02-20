const express = require("express");
const multer = require("multer");
const { spawn } = require("child_process");
const path = require("path");
const pool = require("../config/db");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();
const upload = multer({ dest: "uploads/" });

router.post("/predict", authMiddleware, upload.single("mri"), (req, res) => {

  const imagePath = path.resolve(req.file.path);

  const pythonProcess = spawn("python", [
    path.join(__dirname, "../ml/predict.py"),
    imagePath
  ]);

  let resultData = "";

  pythonProcess.stdout.on("data", (data) => {
    resultData += data.toString();
  });

  pythonProcess.on("close", async () => {

    const result = JSON.parse(resultData);

    await pool.query(
      "INSERT INTO scans (user_id, tumor_type, confidence, report_file) VALUES ($1,$2,$3,$4)",
      [req.user.id, result.classification, result.confidence_score, result.report_file]
    );

    res.json(result);
  });
});

module.exports = router;