Big O, also known as Big O notation, represents an algorithm's worst-case complexity. It uses algebraic terms to describe the complexity of an algorithm.

Big O Notation is a metric for determining the efficiency of an algorithm. It allows you to estimate how long your code will run on different sets of inputs and measure how effectively your code scales as the size of your input increases.

Big O defines the runtime required to execute an algorithm by identifying how the performance of your algorithm will change as the input size grows. But it does not tell you how fast your algorithm's runtime is.

Big O notation measures the efficiency and performance of your algorithm using time and space complexity.
#### ### What is Time and Space Complexity?
An algorithm's time complexity specifies how long it will take to execute an algorithm **as a function of its input size**. Similarly, an algorithm's space complexity specifies the total amount of space or memory required to execute an algorithm **as a function of the size of the input**.
#### Big O Complexity Chart
The Big O chart, also known as the Big O graph, is an asymptotic notation used to express the complexity of an algorithm or its performance as a function of input size.

This helps programmers identify and fully understand the worst-case scenario and the execution time or memory required by an algorithm.

![[Pasted image 20240930203549.png]]

In Big O, there are six major types of complexities (time and space):

- Constant: O(1)
- Linear time: O(n)
- Logarithmic time: O(log n)
- Quadratic time: O(n^2)
- Exponential time: O(2^n)
- Factorial time: O(n!)

Other complexities:

- Log-linear time: O(n log n)
- Cubic time: O(n^3)

The Big O chart shows that O(1), which stands for constant time complexity, is the best. This implies that your algorithm processes only one statement without any iteration. Then there's O(log n), which is good, and others like it, as shown below:

- **O(1)** - Excellent/Best
- **O(log n)** - Good
- **O(n)** - Fair
- **O(n log n)** - Bad
- **O(n^2)**, **O(2^n)** and **O(n!)** - Horrible/Worst

Overview:

- When your calculation is not dependent on the input size, it is a constant time complexity **(O(1))**.
- When the input size is reduced by half, maybe when iterating, handling recursion, or whatsoever, it is a logarithmic time complexity **(O(log n))**.
- When you have a single loop within your algorithm, it is linear time complexity **(O(n))**.
- When you have nested loops within your algorithm, meaning a loop in a loop, it is quadratic time complexity **(O(n^2))**.
- When the growth rate doubles with each addition to the input, it is exponential time complexity **(O2^n)**.
#### Constant Time: O(1)
When your algorithm is not dependent on the input size n, it is said to have a constant time complexity with order O(1). This means that the run time will always be the same regardless of the input size.

For example, if an algorithm is to return the first element of an array. Even if the array has 1 million elements, the time complexity will be constant if you use this approach:

```js
const firstElement = (array) => {
	return array[0];
};

let score = [12, 55, 67, 94, 22];
console.log(firstElement(score)); // 12
```

The function above will require only one execution step, meaning the function is in constant time with time complexity O(1).
#### Linear Time: O(n)
You get linear time complexity when the running time of an algorithm increases linearly with the size of the input. This means that when a function has an iteration that iterates over an input size of n, it is said to have a time complexity of order O(n).

For example, if an algorithm is to return the factorial of any inputted number. This means if you input 5 then you are to loop through and multiply 1 by 2 by 3 by 4 and by 5 and then output 120:

```js
const calcFactorial = (n) => {
	let factorial = 1;
	for (let i = 2; i <= n; i++) {
		factorial = factorial * i;
	}
	return factorial;
};

console.log(calcFactorial(5)); // 120
```

The fact that the runtime depends on the input size means that the time complexity is linear with the order O(n).
#### Logarithm Time: O(log n)
This is similar to linear time complexity, except that the runtime does not depend on the input size but rather on half the input size. When the input size decreases on each iteration or step, an algorithm is said to have logarithmic time complexity.

This method is the second best because your program runs for half the input size rather than the full size. After all, the input size decreases with each iteration.

A great example is binary search functions, which divide your sorted array based on the target value.

For example, suppose you use a binary search algorithm to find the index of a given element in an array:

```js
const binarySearch = (array, target) => {
  let firstIndex = 0;
  let lastIndex = array.length - 1;
  while (firstIndex <= lastIndex) {
    let middleIndex = Math.floor((firstIndex + lastIndex) / 2);

    if (array[middleIndex] === target) {
      return middleIndex;
    }

    if (array[middleIndex] > target) {
      lastIndex = middleIndex - 1;
    } else {
      firstIndex = middleIndex + 1;
    }
  }
  return -1;
};

let score = [12, 22, 45, 67, 96];
console.log(binarySearch(score, 96));
```

In the code above, since it is a binary search, you first get the middle index of your array, compare it to the target value, and return the middle index if it is equal. Otherwise, you must check if the target value is greater or less than the middle value to adjust the first and last index, reducing the input size by half.

Because for every iteration the input size reduces by half, the time complexity is logarithmic with the order O(log n).

**O(n log n)**, which is often confused with **O(log n)**, means that the running time of an algorithm is linearithmic, which is a combination of linear and logarithmic complexity. Sorting algorithms that utilize a divide and conquer strategy are linearithmic, such as the following:

- `merge sort`
- `timsort`
- `heapsort`
#### Quadratic Time: O(n^2)
When you perform nested iteration, meaning having a loop in a loop, the time complexity is quadratic, which is horrible.

A perfect way to explain this would be if you have an array with n items. The outer loop will run n times, and the inner loop will run n times for each iteration of the outer loop, which will give total n^2 prints. If the array has ten items, ten will print 100 times (10^2).

Here is an example where you compare each element in an array to output the index when two elements are similar:

```js
const matchElements = (array) => {
  for (let i = 0; i < array.length; i++) {
    for (let j = 0; j < array.length; j++) {
      if (i !== j && array[i] === array[j]) {
        return `Match found at ${i} and ${j}`;
      }
    }
  }
  return "No matches found 😞";
};

const fruit = ["🍓", "🍐", "🍊", "🍌", "🍍", "🍑", "🍎", "🍈", "🍊", "🍇"];
console.log(matchElements(fruit)); // "Match found at 2 and 8"
```

In the example above, there is a nested loop, meaning that the time complexity is quadratic with the order O(n^2).
#### Exponential Time: O(2^n)
You get exponential time complexity when the growth rate doubles with each addition to the input (n), often iterating through all subsets of the input elements. Any time an input unit increases by 1, the number of operations executed is doubled.

The recursive Fibonacci sequence is a good example. Assume you're given a number and want to find the nth element of the Fibonacci sequence.

```js
const recursiveFibonacci = (n) => {
  if (n < 2) {
    return n;
  }
  return recursiveFibonacci(n - 1) + recursiveFibonacci(n - 2);
};

console.log(recursiveFibonacci(6)); // 8
```

In the code above, the algorithm specifies a growth rate that doubles every time the input data set is added. This means the time complexity is exponential with an order O(2^n).
#### Array sorting algorithms complexity

![[Pasted image 20240930203241.png]]
#### Common data structure operations

![[Pasted image 20240930203405.png]]
#### References
- https://www.bigocheatsheet.com/