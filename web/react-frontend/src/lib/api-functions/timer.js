import { API } from "../api";

export const createTimer = async (duration) => {
    try {
        const response = await fetch(`${API}/timer`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ duration }),
        });

        if (!response.ok) {
            throw new Error('Failed to start timer');
        }

        const data = await response.json();
        console.log(data.message);
    } catch (error) {
        console.error('Error:', error);
    }
}