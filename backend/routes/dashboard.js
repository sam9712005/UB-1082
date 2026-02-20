const express = require("express");
const pool = require("../config/db");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/history", authMiddleware, async (req, res) => {
  const scans = await pool.query(
    "SELECT * FROM scans WHERE user_id=$1 ORDER BY created_at DESC",
    [req.user.id]
  );

  res.json(scans.rows);
});

module.exports = router;