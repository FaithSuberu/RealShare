# RealShare Smart Contract

A Clarity smart contract for tokenizing real-world assets with automated dividend distribution capabilities on the Stacks blockchain. This contract implements the [SIP-010](https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md) fungible token standard.

## Features

- 🏢 Tokenization of real-world assets
- 💰 Automated dividend distribution system
- 🔄 SIP-010 compliant token implementation
- 🔐 Admin-controlled minting and burning
- 💸 Proportional dividend claims

## Technical Overview

The contract maintains several key components:
- Token balances for each holder
- Total token supply tracking
- Dividend per share accounting
- Individual dividend withdrawal states

### Token Details
```clarity
Token Name: RealWorldAsset Shares
Symbol: RWA
Decimals: 6
```

## Functions

### Token Operations
- `transfer(recipient, amount)` - Transfer tokens between users
- `get-balance(owner)` - Check token balance
- `get-total-supply()` - Get current total supply

### Admin Functions
- `admin-mint(recipient, amount)` - Mint new tokens
- `admin-burn(from, amount)` - Burn existing tokens
- `deposit-dividends(amount)` - Deposit STX for dividend distribution

### User Functions
- `claim-dividends()` - Claim available dividends

## Error Codes

| Code | Description |
|------|-------------|
| 100 | Unauthorized mint attempt |
| 101 | Unauthorized burn attempt |
| 102 | Insufficient balance for burn |
| 103 | Insufficient balance for transfer |
| 104 | Unauthorized dividend deposit |
| 105 | No dividends to claim |

## Important Notes

- STX transfers for dividend distribution must be handled off-chain
- Dividend calculations use 1,000,000 as scaling factor for precision
- Only the contract admin can mint/burn tokens and deposit dividends


```bash
clarinet deploy
```

## Testing

Run the test suite:
```bash
clarinet test
```

