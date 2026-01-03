const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
})

const input = (q) => {
    return new Promise(r => rl.question(q, r))
}

const Problem = async () => {
    const stocks = await input("Enter Number of stock days:: ")
    const stockPrices = Array.from({ length: stocks }, () => 0)
    for (let i = 0; i < stocks; i++) {
        stockPrices[i] = await input(`Enter ${i + 1} day of Stock:: `)
    }
    console.log("Stocks List", stockPrices);

    let max = 0;
    let min = Infinity;
    for (let price of stockPrices) {
        if (price < min) {
            min = price;
        } else {
            max = Math.max(max, price - min)
        }
    }
    console.log(`max price of ${stocks} days:: `, max)
    rl.close();
}

Problem();