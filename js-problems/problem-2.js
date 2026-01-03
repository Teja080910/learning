const nums = [1, 3, 0, 4, 2, 0, 6, 0, 5];
console.log(nums.filter(num => num !== 0).concat(nums.filter(num => num === 0)))

const list = [1, 3, 0, 4, 2, 0, 6, 0, 5];
let j = 0;
for (i = 0; i < list.length; i++) {
    if (list[i] !== 0) list[j++] = list[i];
}
while (j < list.length) {
    list[j++] = 0
}

console.log(list)