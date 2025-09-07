# On-Chain Voting Smart Contract

A decentralized voting system implemented in Clarity for the Stacks blockchain.

## Features

- Create proposals with customizable titles, descriptions, and voting duration
- Vote on active proposals (for/against)
- Track voting results in real-time
- Prevent double voting
- Query proposal details and voting status
- Check voter participation

## Contract Functions

### Public Functions

- `create-proposal`: Create a new proposal with title, description, and duration
- `vote`: Cast a vote (true/false) on an active proposal
- `execute-proposal`: Execute passed proposals (implementation pending)

### Read-Only Functions

- `get-proposal`: Get detailed information about a specific proposal
- `get-result`: Get current voting results and status
- `has-voted`: Check if a specific address has voted on a proposal

### Data Storage

- Proposals are stored with unique IDs and track:
  - Title and description
  - Creator address
  - Vote counts
  - Start and end blocks
  - Execution status

## Error Codes

- `u1`: Proposal not found
- `u2`: User has already voted
- `u3`: Proposal not in active voting period
- `u4`: Invalid proposal parameters
- `u5`: Invalid proposal ID

## Usage Example

```clarity
;; Create a new proposal
(contract-call? .on-chain-voting create-proposal 
    "My Proposal" 
    "Description of the proposal" 
    u144)

;; Cast a vote
(contract-call? .on-chain-voting vote u1 true)

;; Check results
(contract-call? .on-chain-voting get-result u1)
```

## Development

This contract is built using Clarity and follows best practices for smart contract development including:
- Input validation
- Type safety
- Proper error handling
- Gas optimization

