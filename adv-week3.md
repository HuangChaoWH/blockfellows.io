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

(3) VISIBILITY
- Keep your functions private or internal unless there is a need for outside interaction.

Why?
- Public functions can be called by anyone
- External functions can only be accessed externally by other contracts. [Demo](https://ethfiddle.com/1q-YzAPV9W)
- Private functions can be called only from inside the contract
- Internal functions are a more relaxed version of private, where contracts that inherit from the parent are able to use the the function














