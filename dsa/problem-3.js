const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
})

const input = (q) => {
    return new Promise(r => rl.question(q, r))
}

const Permitation = async () => {
    const array = [];
    const n = await input("Enter number of elements ::")
    for (let i = 0; i < n; i++) {
        array[i] = await input(`Enter for ${i + 1} element ::`)
    }

    array.sort((a, b) => a - b)

    const permute = (start) => {
        const res = [];
        if (start === n) {

        }
    }

    console.log("This is array result ::", array)
    rl.close();
}

Permitation();