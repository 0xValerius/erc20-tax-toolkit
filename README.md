# 👾 ERC20 Tax Toolkit

The ERC20 Tax Toolkit is a set of modular, composable Solidity smart contracts that can be used to create custom ERC20 tokens with various features such as balance and transfer limiting, blacklisting, and tax handling.

## 📄 Contracts

- **BalanceLimiter** it enforces a balance limit on an ERC20 token. This contract takes a base points balance limit during construction, which represents the percentage of the total supply that each account can hold.

- **TransferLimiter** it enforces a transfer limit on an ERC20 token. This contract takes a base points transfer limit during construction, which represents the percentage of the total supply that each account can transfer in a single transaction.

- **BlackLister** adds the ability to blacklist certain accounts from sending or receiving tokens.

- **TaxHandler** adds the ability to impose a tax on transfers, purchases, and sales of tokens. The tax amount is taken from the transaction value and sent to a treasury account. This contract takes a treasury address, a transfer fee rate, a buy fee rate, and a sell fee rate during construction.

## 📄 Token Implementations

- **BalanceLimitedToken** a custom ERC20 token that inherits from the ERC20 and BalanceLimiter contracts. This token has a balance limit feature, which is enforced through the BalanceLimiter contract.

- **TransferLimitedToken** a custom ERC20 token that inherits from the ERC20 and TransferLimiter contracts. This token has a transfer limit feature, which is enforced through the TransferLimiter contract.

- **BlackListerToken** a custom ERC20 token that inherits from the ERC20 and BlackLister contracts. This token has a blacklisting feature, which is enforced through the BlackLister contract.

- **TaxHandledToken** a custom ERC20 token that inherits from the ERC20 and TaxHandler contracts. This token has a tax handling feature, which is enforced through the TaxHandler contract.

- **BalanceTransferLimitedToken** a custom ERC20 token that inherits from the ERC20, BalanceLimiter, and TransferLimiter contracts. This token has both balance and transfer limiting features, which are enforced through the BalanceLimiter and TransferLimiter contracts.

## :wrench: Development Tools

- **Solidity**: I've used Solidity version **0.8.17** to write the smart contracts in this repository.
- **Foundry**: a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.

## :rocket: Getting Started

1. Clone this repository. `git clone https://github.com/0xValerius/erc20-tax-toolkig.git`
2. Install the required dependencies. `npm install`
3. Compile the smart contracts. `forge build`
4. Run the test suite. `forge test`

## 🤖 Usage

To use the ERC20 Tax Toolkit, simply import the desired contract(s) from the tokens directory and inherit from them in your custom ERC20 token contract. You can also import the individual contracts for more fine-grained control.

## :scroll: License

[MIT](https://choosealicense.com/licenses/mit/)

## 🚨 Disclaimer

The ERC20 Tax Toolkit is provided "as is" and without warranties of any kind, whether express or implied. The user assumes all responsibility and risk for the use of this software.
