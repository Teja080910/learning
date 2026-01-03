const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdin
});

const input = (q) => {
    return new Promise(r => rl.question(q, r));
}

const pascalProblem = async () => {
    const n = await input("Enter number of rows ::")
    const result = []
    for (let i = 0; i < n; i++) {
        result[i] = [];
        for (let j = 0; j <= i; j++) {
            if (j === 0 || j == i) {
                result[i][j] = 1;
            } else {
                result[i][j] = result[i - 1][j - 1] + result[i - 1][j]
            }
        }
    }

    console.log("output", result)

    rl.close();
}

pascalProblem();