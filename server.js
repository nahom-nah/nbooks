require("dotenv").config();

const express = require("express");
const body_parser = require("body-parser");
const morgan = require("morgan");
const cors = require("cors");
const helmet = require("helmet");

const app = express();

const port = process.env.EXPRESS_PORT;

const seed_admin = require("./express/seed/seed-admin");
const jwt = require("./express/middleware/jwt");

app.use(cors());
app.use(body_parser.json({ limit: "100mb" }));
app.use(body_parser.urlencoded({ extended: true }));
app.use(morgan("combined"));
app.use(helmet());

app.use("/auth", require("./express/routes/auth"));

app.listen(port, () => {
  console.log(`Express server listening on ${port}`);
  // seed_admin();
});
