const addTwoNumbersIndex = (nums, target) => {
    let values = {}
    for (let i in nums) {
        const remains = target - nums[i];
        if (values[remains]) {
            return [Number(values[remains]), Number(i)]
        }
        values[nums[i]] = i
    }
}

console.log(addTwoNumbersIndex([11, 7, 2, 15], 9))