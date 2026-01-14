const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
})
const input = (q) => {
    return new Promise(r => rl.question(q, r));
}

const AddTwoNumbers = (l1, l2) => {
    const ans = (Number((l1 ?? 0).join('')) + Number((l2 ?? 0).join(''))).toString().split('').reverse()
    console.log(ans)
    rl.close()
}

AddTwoNumbers([9, 9, 9, 9, 9, 9, 9], [9, 9, 9, 9])