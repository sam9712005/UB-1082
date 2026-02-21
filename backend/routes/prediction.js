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
  let errorData = "";

  pythonProcess.stdout.on("data", (data) => {
    resultData += data.toString();
  });

  pythonProcess.stderr.on("data", (data) => {
    errorData += data.toString();
  });

  pythonProcess.on("close", async (code) => {
    console.log("Python process exited with code:", code);
    console.log("resultData:", resultData);
    console.log("errorData:", errorData);

    if (!resultData.trim()) {
      return res.status(500).json({ message: "Prediction failed: no output from Python script" });
    }

    try {
      const result = JSON.parse(resultData);

      await pool.query(
        "INSERT INTO scans (user_id, tumor_type, confidence, report_file) VALUES ($1,$2,$3,$4)",
        [req.user.id, result.classification, result.confidence_score, result.report_file]
      );

      res.json(result);
    } catch (parseError) {
      console.error("JSON parse error:", parseError);
      res.status(500).json({ message: "Prediction failed: invalid output from Python script" });
    }
  });
});

module.exports = router;