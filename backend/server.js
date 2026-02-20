require("dotenv").config();

const express = require("express");
const cors = require("cors");
const cookieParser = require("cookie-parser");

const authRoutes = require("./routes/auth");
const predictionRoutes = require("./routes/prediction");
const dashboardRoutes = require("./routes/dashboard");

const app = express();

app.use(express.json());
app.use(cors());
app.use(cookieParser());
app.use("/reports", express.static("ml/reports"));

app.use("/", authRoutes);
app.use("/", predictionRoutes);
app.use("/", dashboardRoutes);

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || "0.0.0.0";

app.listen(PORT, HOST, () => {
  console.log(`Server running on ${HOST}:${PORT}`);
});