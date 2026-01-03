const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
})
const input = (q) => {
    return new Promise(r => rl.question(q, r))
}

const PowerOfNum = async () => {
    const x = await input("Enter base number: ");
    const n = await input("Enter power number: ")

    console.log(x ** n);
    rl.close();
}

PowerOfNum();