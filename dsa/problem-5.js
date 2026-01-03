const { count } = require('console');
const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
})
const input = (q) => {
    return new Promise(r => rl.question(q, r));
}

const findMaxIttration = async () => {
    const n = await input("Enter number elements you want :");
    const array = [];
    for (let i = 0; i < n; i++) {
        array[i] = await input(`Enter for ${i + 1} element: `);
    }

    let max = array[0];
    let count = 0;
    let frq = {}
    for (let i of array) {
        frq[i] = (frq[i] || 0) + 1;
        if (frq[i] > count) {
            max = i;
            count = frq[i]
        }
    }
    console.log(max)
    rl.close();
}

findMaxIttration();
