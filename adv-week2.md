# (1) Installation

- Truffle
`npm install -g truffle`

- Ganache CLI
`npm install -g ganache-cli`

- Testrpc
`npm install -g ethereumjs-testrpc`

# (2) Smart contract development

- Folder structure (to follow symmetry)
  - Contracts: contains our source code
  - Migrations: add scripts for staging deployment tasks
  - Test: where you test your contracts for vulnerabilities

- Goto read `code/truffle_example/README.md`

# (3) Global Variables

```
this; // address of contract
this.balance; // often used at end of contract life to send remaining balance to party 
this.someFunction(); // calls func externally via call, not via internal jump


// msg - Current message received by the contract
msg.sender; // address of sender
msg.value; // amount of ether provided to this contract in wei msg.data; // bytes, complete call data
msg.gas; // remaining gas
// tx - This transaction
tx.origin; // address of sender of the transaction, will always be a user tx.gasprice; // gas price of the transaction

// block - Information about current block
now; // current time (approximately), alias for block.timestamp (uses Unix time) block.number; // current block number
block.difficulty; // current block difficulty
block.blockhash(1); // hash of the given block - returns bytes32, only works for most recent 256 blocks
block.gasLimit();
// storage - Persistent storage hash
storage['abc'] = 'def'; // maps 256 bit words to 256 bit words

```

# (4) Functions

- Basic structure
```
// Functions can return many arguments, and by specifying returned // arguments name don't need to explicitly return

function increment(uint x, uint y) returns (uint x, uint y) {
x += 1;
y += 1; 
}

// Call previous function
uint (a,b) = increment(1,1);

```

- Significance of constant
```
// 'constant' indicates that function does not/cannot change persistent vars
// Constant functions execute locally, not on blockchain

uint y;
function increment(uint x) constant returns (uint x) { x += 1;
y += 1; // this line would fail
     // y is a state variable, and can't be changed in a constant function

}
```

- Prefer loops to recursion (max call stack depth is 1024)

```
// Functions hoisted - and can assign a function to a variable
function a() { var z = b;
b(); 
}
function b() {
}
```

