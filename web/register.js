// document.getElementById("label-id").innerHTML = "Name";
// document.getElementById("register-container").style.backgroundColor = "lightblue";

const colorsList = ["red", "green", "blue", "yellow", "orange", "purple"];

const changeColor = () => {
    const randomIndex = Math.floor(Math.random() * colorsList.length);
    const randomColor = colorsList[randomIndex];
    document.getElementById("register-container").style.backgroundColor = randomColor;
}

// let 
// ADU NRI RA
// var
// BDU RI RA
// const
// ADU NRI NRA

// console.log(sample);
// let sample = "This is a sample variable.";
// let sample;
// sample = "This is reassigned value.";
// console.log(sample);

// console.log(sampleVar);
// var sampleVar = "This is a sample variable declared with var.";
// sampleVar = "This is reassigned value for var.";
// console.log(sampleVar);

// let sampleLet;
// var SampleVar;

// const sampleConst = "This is a sample constant variable.";
// sampleConst = "This is reassigned value for const.";
// console.log(sampleConst);
// console.log("This is a sample log message.");

// const a = 10;
// const b = 20;

// const sum = a + b;
// console.log("The sum of a and b is: " + sum);

// let c = 10;
// c += 20; //=> c = c + 20
// c++;
// console.log("The value of c after adding 20 is: " + c);

// const firstBollean = false;
// const secondBollean = false;

// console.log(firstBollean && secondBollean);

// console.log(firstBollean || secondBollean);

// let x = 0;
// console.log(x ?? 5); //=> 5

/*
= ( assignment operator)
== (equality operator) it will not check the data type, it will only check the value
=== (strict equality operator) it will check both value and data type
 */

// const num1 = 10;
// const num2 = "10";

// console.log(num1 == num2);
// console.log(num1 === num2);

// if (num1 === num2) {
//     console.log("Both values and data types are equal.");
// } else if (num1 == num2) {
//     console.log("Both values are equal but data types are not equal.");
// } else {
//     console.log("Both values and data types are not equal.");
// }

// switch (num1) {
//     case 5:
//         console.log("The value is 5.");
//         break;
//     case 10:
//         console.log("The value is 10.");
//         break;
//     default:
//         console.log("The value is neither 5 nor 10.");
// }

// for (let i = 0; i < 5; i++) {
//     console.log("The value of i is: " + i);
// }

// for (const color of colorsList) {
//     console.log("The color is: " + color);
// }

// for (const color in colorsList) {
//     console.log("The color is: " + colorsList[color]);
// }

// while (x < 5) {
//     console.log("The value of x is: " + x);
//     x++;
// }

// do {
//     console.log("The value of x in do-while loop is: " + x);
//     x++;
// } while (x < 5);


const usernameInput = document.getElementById("username");
const emailInput = document.getElementById("email");
const passwordInput = document.getElementById("password");

const store = localStorage;

usernameInput.addEventListener("input", () => {
    // console.log("Username: " + usernameInput.value);
    usernameInput.value = usernameInput.value.trim();
});

emailInput.addEventListener("input", () => {
    // console.log("Email: " + emailInput.value);
    emailInput.value = emailInput.value.trim();
});

passwordInput.addEventListener("input", () => {
    // console.log("Password: " + passwordInput.value);
    passwordInput.value = passwordInput.value.trim();
});

const registerButton = document.getElementById("register");
registerButton.addEventListener("click", () => {
    const regusterData = {
        username: usernameInput.value,
        email: emailInput.value,
        password: passwordInput.value
    }
    console.log("user Data: ", regusterData);
    const existingData = store.getItem("userData");
    const appendedData = existingData ? JSON.parse(existingData) : [];
    if (!regusterData.username) {
        alert("Username cannot be empty. Please enter a username.");
        return;
    }
    if (!regusterData.email) {
        alert("Email cannot be empty. Please enter an email.");
        return;
    }
    if (!regusterData.password) {
        alert("Password cannot be empty. Please enter a password.");
        return;
    }
    if (existingData) {
        const parsedData = JSON.parse(existingData);
        if (parsedData.filter(user => user.username === regusterData.username).length > 0) {
            alert("Username already exists. Please choose a different username.");
            return;
        }
        if (parsedData.filter(user => user.email === regusterData.email).length > 0) {
            alert("Email already exists. Please choose a different email.");
            return;
        }
        if (parsedData.filter(user => user.password === regusterData.password).length > 0) {
            alert("Password already exists. Please choose a different password.");
            return;
        }
        appendedData.push(regusterData);
    } else {
        appendedData.push(regusterData);
    }

    const result = fetch("http://localhost:3000/register", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(regusterData)
    })

    const resultData = result.json();
    console.log("Result Data: ", resultData);

    store.setItem("userData", JSON.stringify(appendedData));
});

// sessionStorage
// localStorage