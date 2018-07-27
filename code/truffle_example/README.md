# Developer Environment Setup
Your task is simply to output the following in your console via the tools/frameworks below:

    "Hello World"

To do so you must:
1. Download this repository
2. Download the required software dependencies
3. Compile the provided `Greeter.sol` "Hello World" smart contract
4. Deploy the smart contract to a test blockchain
5. Use `truffle console` then call the deployed contract's `greet()` function


## Instructions

1. In an empty terminal, run `testrpc` to initialize a default testrpc server. If you get errors, read the [Testrpc documentation](https://github.com/ethereumjs/testrpc) 
2. In a separate terminal, compile your Greeter smart contract with `truffle compile`. [Truffle documentation](http://truffleframework.com/)

## Testing 

You can verify that your smart contract is implemented correctly with `truffle test`.
Be sure to have a testrpc server running in a separate terminal.

## Truffle Console

Once your greeter passes the test:
1. Run `truffle migrate`.
2. Run `truffle console`. This will open up a Node JavaScript console that is connected to your testrpc server. 
```
Greeter.deployed().then(function(instance) {return instance.greet();})
```