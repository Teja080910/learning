import React, { useEffect, useState } from 'react';
import { createTimer } from '../lib/api-functions/timer';

const Timer = (props) => {
    const [time, setTime] = useState(0);
    const [isRunning, setIsRunning] = useState(false);

    useEffect(() => {
        let interval;
        if (isRunning) {
            interval = setInterval(() => {
                setTime((prevTime) => prevTime + 1);
            }, 1000);
        } else {
            clearInterval(interval);
        }
        return () => clearInterval(interval);
    }, [isRunning]);

    const handleStart = () => {
        setIsRunning(true);
    };

    const handleStop = () => {
        setIsRunning(false);
    };

    const handleReset = () => {
        setIsRunning(false);
        handleSubmit(); // Call the handleSubmit function to send the timer data to the backend
        setTime(0);
    };

    const handleSubmit = async () => {
        await createTimer(time);
    };

    return (
        <div className="timer">
            <h1>Welcome to the Timer! {props.name}</h1>
            <h1>Timer: {time} seconds</h1>
            <button onClick={handleStart}>Start</button>
            <button onClick={handleStop}>Stop</button>
            <button onClick={handleReset}>Reset</button>
        </div>
    );
};

export default Timer;