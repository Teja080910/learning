import fs from 'fs/promises';
const readFileByWords = async () => {
    const file = await fs.readFile('data.txt', 'utf-8');
    const words = file.split(/\s+/).filter(Boolean);
    console.log("Words", words);
    const wordss = file.match(/[a-zA-Z]+/g)
    console.log("Words", wordss)
    const letters = file.match(/[a-zA-Z]/g)
    console.log(letters)
}

readFileByWords();