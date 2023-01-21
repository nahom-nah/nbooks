const express = require("express");
const router = express.Router();
const controller = require("../controllers/auth-controller");

router.post("/login", controller.login);
router.post("/create-user", controller.create_user);
router.post("/activate-deactivate", controller.activate_deactivate);
router.post("/update-password", controller.update_password);
router.post("/reset-password", controller.reset_password);
router.post("/update-profile", controller.update_profile);

module.exports = router;
