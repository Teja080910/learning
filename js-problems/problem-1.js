const nums = [1, 2, 3, 4];
const answers = [];
// for (let i = 0; i < nums.length; i++) {
//     let product = 1;
//     for (let j = 0; j < nums.length; j++) {
//         if (i === j) continue;
//         product = product * nums[j];
//     }
//     answers.push(product);
// }

// console.log("answers", answers);

let prefix = 1;
for (let i = 0; i < nums.length; i++) {
    answers[i] = prefix;
    prefix = prefix * nums[i];
}
console.log('Answers', answers)

let suffix = 1;
for (let i = nums.length - 1; i >= 0; i--) {
    answers[i] = answers[i] * suffix
    suffix = suffix * nums[i]
}
console.log('Answers', answers)