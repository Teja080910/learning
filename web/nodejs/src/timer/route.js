import { Router } from "express";
import { createTimer } from "./create-timer.js";

const router = Router();

router.post('/', createTimer);

export default router;
