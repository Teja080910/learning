const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const input = (q) => {
    return new Promise(r => rl.question(q, r));
}


// Time complexity O(n^2)
const findZeros = (array) => {
    let pos = [];
    // Time O(n)
    array.map((array1, i) => {
        // Time O(n)
        array1.map((array2, j) => {
            if (array2 === 0) {
                pos.push({ row: i, col: j })
            }
        })
    });
    return pos;
}

const setZeros = (array, pos) => {
    // Time Complexity O(2n)
    pos.forEach(({ row, col }) => {
        // Time O(n)
        for (let j = 0; j < array[row].length; j++) {
            array[row][j] = 0;
        }
        // Time O(n)
        for (let i = 0; i < array.length; i++) {
            array[i][col] = 0;
        }
    });
    return array
};

const getArray = async () => {
    const n = await input('Enter Number of rows: ')
    // Time complexity O(n^2)
    const array = Array.from({ length: n }, () => Array.from({ length: n }, () => 0));
    // Input -> O(n2)
    // Time O(n)
    for (let i = 0; i < n; i++) {
        // Time O(n)
        for (let j = 0; j < n; j++) {
            array[i][j] = Number(`${await input(`Enter number for matA ${i + 1} : ${j + 1}:: `)}`)
        }
    }

    console.log("Array", array)

    // Output -> O(n^2)
    // Time O(n^2)
    const pos = findZeros(array)

    // Time O(2n) -> (n)
    console.log(setZeros(array, pos))

    rl.close();
}

getArray()