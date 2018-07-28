# (1)  Significance of security in Blockchain

- Consider security in prevention sense i.e. preventing an exploit
- Think of the blockchain as a server, where server side code is completely exposed to the clients on the protocol (network nodes) and clients on DApps (users)
- It’s all public - therefore imperative that secure code is written.
- Blockchain systems are highly experimental. New expolits happen daily and they can be prevented by robust code patterns.
- ETH smart-contracts are immutable i.e. no changes can be made once deployed. Hence, all testing needs to be done before deployment to mainet.
- CD/CI (Jenkins) and Integration Tests are good way to test before deployments.
- Smart contract code audits
- Mathematically prove why the smart contract works i.e. Formally verifiable smart contracts


# (2) Integer Overflow & Underflow

- Suppose you increment a number above it’s max value
- Solidity can handle up to 256 bit numbers (2**256 - 1)
- Overflow: Incrementing the number by 1 would result in 0
- Likewise, in the inverse case, when the number is unsigned, decrementing will underflow the number, resulting in the maximum possible value

Example: to demonstrate Underflow
Link: https://ethfiddle.com/IGJ2w0vPsX
```
pragma solidity 0.4.18;

// Contract to test unsigned integer underflows and overflows
// note: uint in solidity is an alias for uint256

// Guidelines: Press "Create" to the right, then check the values of max and zero by clicking "Call"
// Then, call overflow and underflow and check the values of max and zero again

contract OverflowUnderFlow {
    uint public zero = 0;
    uint public max = 2**256-1;
    
    // zero will end up at 2**256-1
    function underflow() public {
        zero -= 1;
    }
    // max will end up at 0
    function overflow() public {
        max += 1;
    }
}
```

- Both cases are very dangerous, but the underflow case is the more likely one to happen
- Suppose a token holder has X tokens but attempts to spend X+1. If the code doesn’t check for it, the attack may end up being allowed to spend more tokens than he had and his balance underflows to the max integer.
- Demonstrate a code pattern to resolve this: https://ethfiddle.com/6JTMKCSai7
- [OpenZeppelin Solidity](https://github.com/OpenZeppelin/openzeppelin-solidity)

```
pragma solidity ^0.4.18;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract OverflowUnderFlowSafe {
    using SafeMath for uint;
    uint public zero = 0;
    uint public max = 2**256-1;
    
    // Will throw
    function underflow() public {
        zero = zero.sub(1);
    }
    // Will throw
    function overflow() public {
        max = max.add(1);
    }

// Contract to test unsigned integer underflows and overflows
// note: uint in solidity is an alias for uint256

// Guidelines: Press "Create" to the right, then check the values of max and zero by clicking "Call"
// Then, call overflow and underflow and check the values of max and zero again   
}
```

# (3) VISIBILITY
- Keep your functions private or internal unless there is a need for outside interaction.

Why?
- Public functions can be called by anyone
- External functions can only be accessed externally by other contracts. [Demo](https://ethfiddle.com/1q-YzAPV9W)
- Private functions can be called only from inside the contract
- Internal functions are a more relaxed version of private, where contracts that inherit from the parent are able to use the the function


# (4) Fallback Function

- A contract can have exactly one unnamed function. This function cannot have arguments and cannot return anything.
- The function is executed on a call to the contract if none of the other functions match the given function identifier (or if no data was supplied at all)
- Even though the fallback function cannot have arguments, one can still use msg.data to retrieve any payload supplied with the call


# (5) DELETEGATECALL

- delegatecall is identical to a message call (internal transaction) apart from the fact that the code at target address is executed in the context of the calling contract and msg.sender and msg.value do not change their values
- A contract can dynamically load code from a different address at runtime with delegatecall
- Very useful for implementing libraries and modularizing code But opens doors to vulnerabilities as your contract is allowing anyone to do whatever they
want with their state

```
contract D {
   uint public n;
   address public sender;
   function delegatecallSetN(address _e, uint _n) { 
   	_e.delegatecall(bytes4(sha3(setN(uint256))), _n); /* D's storage is set, E is not modified */
   	} 
   }
  contract E {
   uint public n;
   address public sender;
   function setN(uint _n) {
n = _n;
     sender = msg.sender;
   }
}
```

# (6) DELETEGATECALL vs CALLCODE vs CALL

- DELETEGATECALL: Delegatecall says “I’m a contract and I’m allowing (delegating) you to do whatever you want to my storage”. If Alice invokes Bob who does delegatecall to Charlie, the msg.sender in the delegatecall is
Alice.
- CALLCODE: If callcode was used the msg.sender would be Bob.
- CALL: When contract D does a call on contract E, the code runs in the context of E: the storage of E is used.

# (7) Attack scenarios

## Parity attack: The vulnerable contract’s function implemented delegatecall and a function from another contract that could modify ownership was left public. That allowed an attacker to craft the msg.data field to call the vulnerable function.

## DAO Attack: Solidity’s call function when called with value forwards all the gas it received.

"In simple words, it’s like the bank teller doesn’t change your balance until she has given you all the money you requested. Can I withdraw $500? Wait, before that, can I withdraw $500? And so on.
The smart contracts as designed only check you have $500 at the beginning, once, and allow themselves to be interrupted.”

```
//Lets reduce sender's balance
function withdraw(uint _amount) public { if(balances[msg.sender] >= _amount) {
                          if(msg.sender.call.value(_amount)()) {
                            _amount;
}
                          balances[msg.sender] -= _amount;
                        }
}
```
- This can be prevented by using the following code patterns:
  -  Reduce the sender’s balance before making the transfer of value
  -  Use mutexes to mitigate race conditions
  -  use `require(msg.sender.transfer(_value))`. [More here](https://medium.com/blockchannel/the-use-of-revert-assert-and-require-in-solidity-and-the-new-revert-opcode-in-the-evm-1a3a7990e06e)

## Solidity selfdestruct
- It renders the contract useless, effectively deleting the bytecode at that address
- It sends all the contract’s funds to a target address

"Due to the throwing fallback function, normally the contract cannot receive ether. However, if a contract selfdestructs with this contract as a target, the fallback function does not get called.
As a result this.balance becomes greater than 0, and thus the attacker can bypass the require statement in
onlyNonZeroBalance"

```
//Lets empty your balance, shall we!
pragma solidity 0.4.18; contract ForceEther { 
	bool youWin = false;
	function onlyNonZeroBalance() { 
		require(this.balance > 0); 
		youWin = true;
}
 // throw if any ether is received
 function() payable {
   revert();
} }
```



