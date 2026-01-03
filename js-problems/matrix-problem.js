const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const input = (q) => {
    return new Promise(r => rl.question(q, r));
}

const AddMatrix = async () => {
    const n = await input('Enter Number of rows: ')
    const matA = Array.from({ length: n }, () => Array.from({ length: n }, () => 0));
    const matB = Array.from({ length: n }, () => Array.from({ length: n }, () => 0));
    const matC = Array.from({ length: n }, () => Array.from({ length: n }, () => 0));
    console.log("matA", matA)
    console.log("matB", matB)
    console.log("matC", matC)
    for (let i = 0; i < n; i++) {
        for (let j = 0; j < n; j++) {
            matA[i][j] = Number(`${await input(`Enter number for matA ${i + 1} : ${j + 1}:: `)}`)
        }
    }
    console.log("matA", matA)
    for (let i = 0; i < n; i++) {
        for (let j = 0; j < n; j++) {
            matB[i][j] = Number(`${await input(`Enter number for matB ${i + 1} : ${j + 1}:: `)}`)
        }
    }

    console.log('matB', matB)

    for (let i = 0; i < n; i++) {
        for (let j = 0; j < n; j++) {
            matC[i][j] = Number(matA[i][j]) + Number(matB[i][j]);
        }
    }

    console.log('Final matrix', matC)
}

AddMatrix();