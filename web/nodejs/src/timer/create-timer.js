// Simulates a countdown timer for the given duration in seconds.
// Runs the countdown synchronously (no dangling interval in the server).
export const createTimer = (req, res) => {
    const { duration } = req.body;

    if (!duration || typeof duration !== 'number' || duration <= 0) {
        return res.status(400).json({ error: 'Invalid duration. Please provide a positive number.' });
    }

    const remainingTime = duration;
    res.status(200).json({
        message: `Timer started for ${duration} seconds.`,
        duration,
        remainingTime
    });
};
