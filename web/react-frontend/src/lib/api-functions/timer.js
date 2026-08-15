import { API } from "../api";

export const createTimer = async (duration) => {
    const response = await fetch(`${API}/timer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ duration }),
    });

    if (!response.ok) {
        const data = await response.json().catch(() => null);
        throw new Error(data?.error || 'Failed to start timer');
    }

    return response.json();
}
