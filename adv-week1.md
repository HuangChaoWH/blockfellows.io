# (1) ETH VM 101

- Ethereum implements an execution environment known as the Ethereum Virtual Machine
- Nodes will go through the transactions listed in the block they are verifying and run the code as triggered by the transaction within the EVM
- Every full node does the same calculations and stores the same values

# (2) Solidity 101

- Solidity lets you program on Ethereum, a blockchain-based virtual machine that allows the creation and execution of smart contracts, without requiring centralized or trusted parties.
- Like objects in OOP, each contract contains state variables, functions, and common data types
- Contract-specific features include modifier (guard) clauses, event notifiers for listeners, and custom global variables

# (3) Hello world program in solidity
- This is saved as `code/greeter.sol`
- The contract cannot be payable; if a user attempts to pay into the contract, they should have all their money refunded

```
pragma solidity ^0.4.16;


contract Greeter {
	/* Add one variable to hold our greeting */
	string greeting;

	function Greeter(string _greeting) public {
		/* Write one line of code for the contract to set our greeting */
	}

	function greet() constant returns (string)  {
		/* Write one line of code to allow the contract to return our greeting */
	}

	/* Add a fallback function to prevent contract payability and non-existent function calls */
	
}
```

# (4)  Fibonacci number program in solidity

- This is saved as `code/fibonacci.sol`
- Build a simple contract that returns the integer in position (n) in the Fibonacci sequence.
- Fibonacci numbers are the numbers in the following integer sequence:
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144...

As seen [here](https://en.wikipedia.org/wiki/Fibonacci_number), the sequence `F(n)` is defined by the recurrence relation:
```F(n) = F(n-1) + F(n-2)```
where F(0) = 0 and F(1) = 1
All work should be done in Fibonacci_skeleton.sol**

- The contract must be able to handle any value of (n), starting from 0
- The contract cannot be payable; if a user attempts to pay into the contract, they should have all their money refunded

```
pragma solidity ^0.4.2;

contract Fibonacci {

    event Notify(uint input, uint result);

    function fibonacci(uint number) constant returns(uint result) {
        if (number == 0) return 0;
        else if (number == 1) return 1;
        else return Fibonacci.fibonacci(number - 1) + Fibonacci.fibonacci(number - 2);
    }

    function fibonacciNotify(uint number) returns(uint result) {
        result = fibonacci(number);
        Notify(number, result);
    }
}
```