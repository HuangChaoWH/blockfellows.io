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

# (5) The simple bank contract (commented)
- This is saved as `code/simplebank.sol`

```
// Declare the source file compiler version
pragma solidity ^0.4.19;

// Start with Natspec comment (the three slashes)
// used for documentation - and as descriptive data for UI elements/actions

/// @title SimpleBank
/// @author nemild

/* 'contract' has similarities to 'class' in other languages (class variables,
inheritance, etc.) */
contract SimpleBank { // CapWords
    // Declare state variables outside function, persist through life of contract

    // dictionary that maps addresses to balances
    // always be careful about overflow attacks with numbers
    mapping (address => uint) private balances;

    // "private" means that other contracts can't directly query balances
    // but data is still viewable to other parties on blockchain

    address public owner;
    // 'public' makes externally readable (not writeable) by users or contracts

    // Events - publicize actions to external listeners
    event LogDepositMade(address accountAddress, uint amount);

    // Constructor, can receive one or many variables here; only one allowed
    function SimpleBank() public {
        // msg provides details about the message that's sent to the contract
        // msg.sender is contract caller (address of contract creator)
        owner = msg.sender;
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit() public payable returns (uint) {
        // Use 'require' to test user inputs, 'assert' for internal invariants
        // Here we are making sure that there isn't an overflow issue
        require((balances[msg.sender] + msg.value) >= balances[msg.sender]);

        balances[msg.sender] += msg.value;
        // no "this." or "self." required with state variable
        // all values set to data type's initial value by default

        LogDepositMade(msg.sender, msg.value); // fire event

        return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    function withdraw(uint withdrawAmount) public returns (uint remainingBal) {
        require(withdrawAmount <= balances[msg.sender]);

        // Note the way we deduct the balance right away, before sending
        // Every .transfer/.send from this contract can call an external function
        // This may allow the caller to request an amount greater
        // than their balance using a recursive call
        // Aim to commit state before calling external functions, including .transfer/.send
        balances[msg.sender] -= withdrawAmount;

        // this automatically throws on a failure, which means the updated balance is reverted
        msg.sender.transfer(withdrawAmount);

        return balances[msg.sender];
    }

    /// @notice Get balance
    /// @return The balance of the user
    // 'constant' prevents function from editing state variables;
    // allows function to run locally/off blockchain
    function balance() constant public returns (uint) {
        return balances[msg.sender];
    }
}
// ** END EXAMPLE **

```

# (6) The basics of Solidity

## 1. DATA TYPES AND ASSOCIATED METHODS




## 2. DATA STRUCTURES

## 3. Simple operators

## 4. Global Variables of note

## 5. FUNCTIONS AND MORE

## 6. BRANCHING AND LOOPS

## 7. OBJECTS/CONTRACTS

## 8. OTHER KEYWORDS

## 9. CONTRACT DESIGN NOTES

## 10. OTHER NATIVE FUNCTIONS

- Currency units: Currency is defined using wei, smallest unit of Ether
```
uint minAmount = 1 wei;
uint a = 1 finney; // 1 ether == 1000 finney
// Other units, see: http://ether.fund/tool/converter
```

- Time units
```
1 == 1 second
1 minutes == 60 seconds
```

- Can multiply a variable times unit, as units are not stored in a variable
```
uint x = 5;
(x * 1 days); // 5 days
```

- Careful about leap seconds/years with equality statements for time (instead, prefer greater than/less than)

- Cryptography: All strings passed are concatenated before hash action
```
sha3("ab", "cd");
ripemd160("abc");
sha256("def");
```

## 11. SECURITY

- Thinking about Smart Contract Security: https://blog.ethereum.org/2016/06/19/thinking-smart-contract-security/
- Hackingdistributed: http://hackingdistributed.com/
- Major issues: https://blog.ethereum.org/2016/06/10/smart-contract-security/


## 12. LOW LEVEL FUNCTIONS

- call - low level, not often used, does not provide type safety
`successBoolean = someContractAddress.call('function_name', 'arg1', 'arg2');`

- callcode - Code at target address executed in *context* of calling contract provides library functionality
`someContractAddress.callcode('function_name');`


## 13. STYLE NOTES

- Based on Python's PEP8 style guide. Full Style guide: http://solidity.readthedocs.io/en/develop/style-guide.html
- 4 spaces for indentation
- Two lines separate contract declarations (and other top level declarations)
- Avoid extraneous spaces in parentheses
- Can omit curly braces for one line statement (if, for, etc)
- else should be placed on own line


## 14. NATSPEC COMMENTS

- used for documentation, commenting, and external UIs
- Contract natspec - always above contract definition
```
/// @title Contract title
/// @author Author name
```

- Function natspec
```
/// @notice information about what function does; shown when function to execute
/// @dev Function documentation for developer
```

- Function parameter/return value natspec
```
/// @param someParam Some description of what the param does
/// @return Description of the return value
```
