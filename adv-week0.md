# (1) Install geth on osx
```
brew tap ethereum/ethereum
brew install ethereum
```

# (2) Use geth to sync with rinkeby testnet
`geth --rinkeby --syncmode "fast"`
- Purpose of a testnet can be summed up as a development environment without using real Ethers (and subsequently fiat money you used to buy these Ethers) to deploy and play around with your smart contracts.
- Three testnest: rinkeby, Ropsten, Kovan 

# (3) Create a new account 
`geth account new`

# (4) Connect to the rinkeby testnet
- start geth with rinkeby (terminal 01)
`geth --rinkeby`

- connect to the testnet (terminal 02)
```
geth --datadir=$HOME/.rinkeby attach ipc:$HOME/Library/Ethereum/rinkeby/geth.ipc console
> personal.newAccount("password") #Outcome is 0x5adaebf9f6e91a25fd66fd7b28c29d5a73e5389b
> eth.coinbase #Outcome is 0x5adaebf9f6e91a25fd66fd7b28c29d5a73e5389b
> eth.getBalance(eth.coinbase) #Outcome is 0, this should increase as soon as the people start sending you tokens
> exit
```

# (5) Where is my chaindata stored?
`geth --rinkeby --syncmode "fast"`
- On OSX: `~/Library/Ethereum`

# (6) Truffle
- Development enviorment and testing framework
`npm install -g truffle`
- How to debug and start a new truffle based smart contract: https://truffleframework.com/tutorials/debugging-a-smart-contract

# (7) Ganache 
- Private ethereum blockchain to simulate full client behaviour
- Simply download and install: https://truffleframework.com/ganache