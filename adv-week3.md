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

## (7.1) Parity attack: The vulnerable contract’s function implemented delegatecall and a function from another contract that could modify ownership was left public. That allowed an attacker to craft the msg.data field to call the vulnerable function.

## (7.2) DAO Attack: Solidity’s call function when called with value forwards all the gas it received.

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

## (7.3) Solidity selfdestruct
- It renders the contract useless, effectively deleting the bytecode at that address
- It sends all the contract’s funds to a target address
- Never use a contract’s balance as a guard

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
} 
}
```
## (7.4) DOS Attack to unsecured contracts
- DOS (Denial of service):  interruption in an authorized user's access to a computer network, typically one caused with malicious intent.
-In this case, an attacker’s contract could first claim leadership by sending enough ether to the insecure contract. Then, the transactions of another player who would attempt to claim leadership would throw.

- Link: https://ethfiddle.com/jJNl3ILO-Z
```
//Ponzi scheme contract
pragma solidity ^0.4.18;
contract CallToTheUnknown {
  // Highest bidder becomes the Leader. 
  // Vulnerable to DoS attack by an attacker contract which reverts all transactions to it.

    address currentLeader;
    uint highestBid;

    function() payable {
        require(msg.value > highestBid);
        require(currentLeader.send(highestBid)); // Refund the old leader, if it fails then revert
        currentLeader = msg.sender;
        highestBid = msg.value;
    }
}

contract Pwn {
  // call become leader 
  function becomeLeader(address _address, uint bidAmount) {
    _address.call.value(bidAmount);
  }
    
  // reverts anytime it receives ether, thus cancelling out the change of the leader
  function() payable {
    revert();
  }
}
```


## (7.5) Shortest address attack (exchange get hacked!)

- Good read: https://vessenes.com/the-erc20-short-address-attack-explained/
- Allows an attacker to abuse the transfer function of an ERC20 (standard token contract) to withdraw a larger amount than he is allowed to.
- Suppose we have an exchange with a wallet of 1000 tokens (ERC-20 spec) and a user with a balance of 32 tokens on that exchange’s wallet.
  - User will go to the exchange, click the token’s withdraw button and input their address without the trailing zeroes (exchange does not perform input validation and let’s the txn go through despite invalid address length)
  - User address: 0x12345600 )(trainling zeros)

- Lets explain this:
  - The server taking in user data allowed an Ethereum address that was less than 20 bytes: usually an Ethereum address looks like 0x1234567890123456789012345678901234567800
  - Lets leave off the trailing zeros: 0x12345678901234567890123456789012345678, where one hex byte equal to 0.
  - The transfer function arguments get shifted over one byte from the point that a short argument was given, and this shifts over the number of tokens transferred

- Lets do an attack pattern
  - Let's say I have 1,000 tokens and would like 256,000 -- what do I do?
    - Generate an Ethereum address with a trailing 0. Ethereum addresses are generated pretty much randomly, so on average this will take 256 tries -- almost no time at all.
    - Find an exchange wallet with 256,000 tokens.
    - Send 1,000 tokens to this exchange wallet, crediting my account internally (off chain) with 1,000.
    - Request a withdrawal of 1,000 tokens using my generated address. Critically I will leave off my last "0" byte.
    - If the server does not validate the address, it will "pack" everything together and move the amount, the final argument, over one byte, yielding a 67 byte argument to the transfer function when 68 is what's needed.
    - All these arguments are passed around under the hood in the msg.data portion of a call. msg.data has three components -- the function signature -- a hash of the name of the function, then the two arguments, address and amount. In ERC20, amount is a uint256, so it has lots of leading zeros.
    - What happens in this attack is that one byte of leading zeros is taken from the amount, and given to the shortened address. This leaves us with the same address as we started with, so tokens sent here will be transferable.
    - When the parser is getting to the end of its bytes, it has an underflow -- there aren't enough bytes left to make a uint256 -- so it just adds zeros to the end and calls it a day. This means you've multiplied your amount by 1<<8 or 256, and crucially after the exchange has checked your balance on their internal ledger.
    - You could even probably get some plausible deniability if you needed -- "Oops, I just copied it over and missed the 0, sorry!"


- How to fix:
  - Throw if msg.data has invalid size
  - Exchanges must perform input validation

## (7.6) Randomness is difficult to achieve 


- Great article: https://ethereum.stackexchange.com/questions/191/how-can-i-securely-generate-a-random-number-in-my-smart-contract
- Everything on the EVM is deterministic (A deterministic model will thus always produce the same output from a given starting condition or initial state)
- Fix: See RANDAO and BLOCK.HASH
- link: https://github.com/randao/randao
- What is blockhash: https://ethereum.stackexchange.com/questions/2100/what-is-a-block-hash
- Everywhere blockhash cannot be used: https://ethereum.stackexchange.com/questions/419/when-can-blockhash-be-safely-used-for-a-random-number-when-would-it-be-unsafe


# (8) Best practices

- Don’t write fancy code
- Use audited and tested code
- Write as many unit tests as possible
- Prepare for failure - at any moment, in any contract or method
- Rollout carefully - bug bounties before ICO
- Keep contracts simple - more complexity = more attack vectors
- Keep updating with software and community
- Beware of blockchain properties: public vs. private, .send() vs. .call()

# (9) Design Patterns

## (9.1) Avoid External Calls

- Avoid a call from one contract to another untrusted contract or account.
- delegatecall, callcode, call
- Types of attacks: The Dao hack, The Parity multisignature wallet hack
- Use `.send()` and `.transfer()` over `.call.value()`

### `.call.value()`

- `somaddress.call.value(ether)()`
- The executed code is is given all the gas making it unsafe

### `.send()`

- `somaddress.send(ether)`
- The executed code is is given limited gas. If it doesn't have enough, it will fail with a boolean.

### `.transfer()`

- `somaddress.transfer(ether)`
- Equivalent to `if(!someaddress.send(ether)) throw;`


## (9.2) revert is the new throw

- revert() returns unused gas
- throw() will continue to consume all gas

## (9.3) assert and require are the king

- `require(condition)` for input validation
- `assert(condition)` for internal error check

## (9.4) pragma declarations

- BAD:
 `pragma solidity ^0.4.18;`

- GOOD:
 `pragma solidity 0.4.18;`

## (9.5) Round all your intergers with divison

- BAD:
```
uint x = 5 / 2; // Result is 2, all integer division rounds DOWN to the nearest integer
```

- GOOD:

```
uint multiplier = 10;
uint x = (5 * multiplier) / 2;
uint numerator = 5;
uint denominator = 2;
```

## (9.6) How to resolve privacy when all data is public?

- Gread read: https://blog.ethereum.org/2016/01/15/privacy-on-the-blockchain/
- Keep user roles to keep access rights.


## (9.7) Offline contracts shouldn't be paid

- Never make a payout untill both contracts talking to each other make the move.

## (9.8) Audit and Quality control

- Use Test Coverage

### (9.8.1) Code analysis
- (1) Use solc: https://solidity.readthedocs.io/en/v0.4.24/installing-solidity.html
It has some good syntax quality check

```
npm install -g solc
docker run ethereum/solc:stable solc --version
```

- (2) securify.ch (https://securify.ch/)
Lets use the underflow example
```
pragma solidity 0.4.24;

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

- (3) Remix (https://remix.ethereum.org/#optimize=false&version=soljson-v0.4.24+commit.e67f0147.js)
Lets use the underflow example for demo

- (4) oyente (https://github.com/melonproject/oyente)

```
#evaluate a local solidity contract
python oyente.py -s <contract filename>
```

### (9.8.2) Frameworks

- Hydra (https://github.com/IC3Hydra/Hydra)
- Porosity (https://github.com/comaeio/porosity)
- Manticore (https://github.com/trailofbits/manticore/)
- EthersPlay (https://github.com/trailofbits/ethersplay)

### (9.8.3) OpenZeppelin

- Link: https://github.com/OpenZeppelin/openzeppelin-solidity
- A framework to build secure smart contracts on Ethereum
- Design patterns: https://blog.zeppelin.solutions/onward-with-ethereum-smart-contract-security-97a827e47702

### (9.8.4) Visualisation Tools (SOLGRAPH)

- https://github.com/raineorshine/solgraph
- Generates a DOT graph that visualizes function control flow of a Solidity contract and highlights potential security vulnerabilities.


# (10) DAO was hacked (Case study)- The birth of ETH Classic

- DAO is a Dentralised Autonomous Organisation.
  - Raised Ether, give tokens that allow you to vote on which projects to fund.
- 3.6m ETHER was stolen (about 70m USD) 
- It was a Reentrency Attack

## (10.1) How did the attack happened?

- Attacker was able to ask the smart contract (DAO) to give the ether back multiple times before the smart contract could update its own balance.
- The design had two functions
  - SplitDAO i.e. withdrawRewardFor, allowing you to withdraw 30X DAO tokens, as you have access to it.
  - Recurrsive SplitDAO Strategy i.e. run this function multiple times.

## (10.2) Hacked, now what?

- A new hard fork of new ETH was launched.
- The transactions related to DAO were reverted and all transactions post DAO are on the chain.
- Rumours have it the hackers were only able to take 1/3 DAO tokens as they ran out of GAS.

# (11) Parity-Ethereum v1.5 Vunerability

- Check Parity, the ETH Client: https://github.com/paritytech/parity-ethereum
- In ETH, we deploy wallet contracts and store the money in that contract account (unlike bitcoin)
- Check this: https://etherscan.io/address/0xb3764761e297d6f121e79c32a65829cd1ddb4d32#internaltx
- Three ICO projects: Edgeless casino, Swarm City and aeternity, were using parity client to manage funds raised during ICO. This was about 30m+ USD. All stolen.
- See code comparision, that fixed this patch: https://github.com/paritytech/parity-ethereum/pull/6102/files
