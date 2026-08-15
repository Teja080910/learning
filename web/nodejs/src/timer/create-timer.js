export const createTimer = (req, res) => {
    const { duration } = req.body;
    if (!duration || typeof duration !== 'number' || duration <= 0) {
        return res.status(400).json({ error: 'Invalid duration. Please provide a positive number.' });
    }

    let remainingTime = duration;
    const timerId = setInterval(() => {
        remainingTime -= 1;
        console.log(`Remaining time: ${remainingTime} seconds`);
        if (remainingTime <= 0) {
            clearInterval(timerId);
            console.log('Timer completed!');
        }
    }, 1000);

    res.status(200).json({ message: `Timer started for ${duration} seconds.` });
};