## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Smart Contract

### Purchase Activity Score:

Each trading pair's purchase activity is capped at 10,000 purchases. Any purchases beyond this limit do not contribute to the score.

$Purchase Activity Score=\frac{Number of Purchases}{10,000}$
​
### Trading Volume Score:

$Trading Volume Score=\frac{Trading Pair’s Volume}{Maximum Trading Volume across all trading pairs}$

### Market Cap Score:

$Market Cap Score = \frac{Trading Pair’s Market Cap}{Maximum Market Cap across all trading pairs}$
​
### Weight Distribution:

- Purchase Activity (W1): 0.2
- Trading Volume (W2): 0.3
- Market Cap (W3): 0.5

### Final Score Calculation:

$Score=0.2\times Purchase Activity Score+0.3\times Trading Volume Score+0.5\times Market Cap Score$
