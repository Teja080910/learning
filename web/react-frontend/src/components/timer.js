import { useEffect, useState } from 'react';
import { createTimer } from '../lib/api-functions/timer';
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';

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
            <Stack direction="row" spacing={2} style={{ marginTop: '20px', display: 'flex', justifyContent: 'center' }}>
                <Button variant="contained" color="primary" onClick={handleStart} disabled={isRunning}>
                    Start
                </Button>
                <Button variant="contained" color="secondary" onClick={handleStop} disabled={!isRunning}>
                    Stop
                </Button>
                <Button variant="contained" color="error" onClick={handleReset}>
                    Reset
                </Button>
            </Stack>

            <h1>Completed Concepts</h1>
            <Stack direction="column" spacing={4}>
                <p>Set up react js ( basic concepts )</p>
                <p>React components and props</p>
                <p>React state and lifecycle</p>
                <p>React hooks ( useState, useEffect )</p>
                <p>React events</p>
                <p>React router</p>
                <p>API Integration</p>
                <p>Material UI</p>
            </Stack>
        </div>
    );
};

export default Timer;