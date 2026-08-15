export const API = "http://localhost:5000";

// Thin fetch wrapper: parses JSON, throws on non-2xx with the server error message.
export const request = async (path, options = {}) => {
    const response = await fetch(`${API}${path}`, {
        headers: { 'Content-Type': 'application/json' },
        ...options,
    });

    const data = await response.json().catch(() => null);

    if (!response.ok) {
        const message = data?.error || `Request failed with status ${response.status}`;
        throw new Error(message);
    }

    return data;
};
