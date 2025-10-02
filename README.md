# 🏠 LedgerX - Real Estate Tokenization Platform

[![Stacks](https://img.shields.io/badge/Built%20on-Stacks-5546FF?style=for-the-badge&logo=stacks&logoColor=white)](https://www.stacks.co/)
[![Clarity](https://img.shields.io/badge/Smart%20Contracts-Clarity-purple?style=for-the-badge)](https://clarity-lang.org/)
[![Bitcoin](https://img.shields.io/badge/Secured%20by-Bitcoin-F7931A?style=for-the-badge&logo=bitcoin&logoColor=white)](https://bitcoin.org/)


A decentralized real estate tokenization platform built on Stacks blockchain that enables fractional property ownership through NFT-based tokens. LedgerX democratizes real estate investment by lowering capital barriers and providing liquidity to traditionally illiquid assets.

## 📑 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Smart Contracts](#smart-contracts)
- [Developer Guide](#developer-guide)
- [Testing](#testing)
- [Deployment](#deployment)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)
- [Contributing](#contributing)

---

## 🎯 Overview

LedgerX solves the fundamental problem of real estate investment accessibility by tokenizing physical properties into fractional NFT tokens. Traditional real estate requires large capital investments and suffers from illiquidity. Our platform enables:

- **Fractional Ownership**: Purchase partial property shares starting from minimal investments
- **Enhanced Liquidity**: Trade property tokens on secondary markets
- **Transparent Pricing**: Real-time property valuation through decentralized oracles
- **Bitcoin Security**: Inherit Bitcoin's security through Stacks Layer 2

### Why Stacks?

Built on Stacks to leverage:
- Bitcoin's security without modifying its protocol
- Clarity's decidability for predictable smart contract behavior
- Proof of Transfer (PoX) consensus mechanism
- Sub-10-second finality (Nakamoto upgrade)

---

## ✨ Key Features

### Core Functionality

#### 1. **Property Tokenization**
- Create tokenized real estate properties with unique identifiers
- Define total property value and token supply
- Automatic price-per-token calculation
- Property metadata storage (address, valuation, status)

#### 2. **Fractional NFT System**
- Mint property-backed NFT tokens representing ownership shares
- ERC-721-compatible token structure with property linkage
- Unique token IDs combining property ID + token index
- Token URI generation for metadata standards

#### 3. **Decentralized Trading**
- Peer-to-peer token buying and selling
- Dynamic pricing based on market demand
- Automatic price discovery mechanism
- Transaction history and ownership tracking

#### 4. **Oracle Price Feeds**
- Real-time property valuation from registered oracles
- Confidence-weighted price aggregation
- Multi-oracle consensus mechanism
- Market indicator tracking (24h, 7d changes)

#### 5. **Governance & Control**
- Property owner controls (pause/resume trading)
- Oracle registration and stake management
- Access control for administrative functions
- Emergency circuit breakers

#### 6. **Transaction Recording**
- Complete purchase history on-chain
- Seller-buyer tracking for each token
- Price history and transaction timestamps
- Ownership provenance

---

## 🏗️ Architecture

### System Components

┌─────────────────────────────────────────────────────────────┐
│ LedgerX Platform │
├─────────────────────────────────────────────────────────────┤
│ │
│ ┌─────────────────┐ ┌──────────────┐ ┌───────────────┐ │
│ │ propertyTokenizer│ │ NFTToken │ │ priceOracle │ │
│ │ │ │ │ │ │ │
│ │ - Create Props │ │ - Mint NFTs │ │ - Price Feeds │ │
│ │ - Buy/Sell │ │ - Transfer │ │ - Aggregation │ │
│ │ - Price Mgmt │ │ - Metadata │ │ - Oracles │ │
│ └─────────────────┘ └──────────────┘ └───────────────┘ │
│ │ │ │ │
└───────────┼───────────────────┼──────────────────┼───────────┘
│ │ │
└───────────────────┴──────────────────┘
│
┌───────────▼───────────┐
│ Stacks Blockchain │
│ (Layer 2) │
└───────────┬───────────┘
│
┌───────────▼───────────┐
│ Bitcoin Network │
│ (Security Layer) │
└───────────────────────┘

text

### Smart Contract Structure

#### **propertyTokenizer.clar**
Core contract managing property lifecycle and token economics.

**Data Structures:**
- `properties`: Map storing property details (owner, address, value, tokens)
- `token-ownership`: Map tracking token ownership per property
- `price-history`: Map recording historical token prices

**Key Functions:**
- `create-tokenized-property`: Initialize new property
- `buy-token`: Purchase property token
- `get-current-price`: Retrieve latest token price
- `pause-property` / `resume-property`: Trading controls

#### **NFTToken.clar**
NFT implementation for property-backed tokens.

**Data Structures:**
- `token-data`: Map storing NFT metadata (property-id, token-index)
- `token-uris`: Map for token metadata URIs
- `nft-ownership`: Map tracking current NFT owners

**Key Functions:**
- `mint-property-tokens`: Batch mint tokens for a property
- `transfer`: Transfer NFT ownership
- `get-owner`: Query token owner
- `get-token-uri`: Retrieve token metadata

#### **priceOracle.clar**
Decentralized oracle system for property valuation.

**Data Structures:**
- `oracles`: Map of registered oracle providers
- `price-feeds`: Map storing oracle-submitted prices
- `market-indicators`: Map tracking market trends

**Key Functions:**
- `register-oracle`: Add new oracle provider
- `submit-price-feed`: Oracle submits property valuation
- `get-aggregated-price`: Calculate consensus price
- `update-market-indicator`: Update macro market trends

---

## 📋 Prerequisites

### Required Software

| Tool | Version | Purpose |
|------|---------|---------|
| **Node.js** | ≥ 18.x | Runtime environment |
| **npm** or **yarn** | Latest | Package manager |
| **Clarinet** | ≥ 2.0 | Clarity development environment |
| **Git** | Latest | Version control |
| **Leather Wallet** | Latest | Stacks wallet (browser extension) |

### Optional Tools

- **Stacks CLI** (`@stacks/cli`): Command-line utilities
- **VS Code**: Recommended IDE with Clarity extension
- **Hiro Platform**: Cloud devnet (alternative to local setup)

### System Requirements

- **OS**: macOS, Linux, or Windows (WSL2)
- **RAM**: Minimum 4GB
- **Storage**: 500MB for dependencies

---

## 🚀 Installation

### 1. Clone Repository

git clone https://github.com/jbhavya876/LedgerX.git
cd LedgerX

text

### 2. Install Node Dependencies

npm install

or
yarn install

text

**Core Dependencies:**
{
"@stacks/transactions": "^6.x",
"@stacks/network": "^6.x",
"dotenv": "^16.x",
"node-fetch": "^2.x"
}

text

### 3. Install Clarinet

**macOS/Linux:**
brew install clarinet

text

**Windows:**
winget install clarinet

text

**Manual Installation:**
curl -L https://github.com/hirosystems/clarinet/releases/latest/download/clarinet-linux-x64.tar.gz | tar xz
sudo mv clarinet /usr/local/bin/

text

### 4. Verify Installation

clarinet --version
node --version
npm --version

text

---

## ⚙️ Configuration

### 1. Create Environment File

cp .env.example .env

text

### 2. Configure `.env`

============================================================================
NETWORK CONFIGURATION
============================================================================
NETWORK=testnet
PLATFORM=hiro
CORE_API_URL=https://api.testnet.hiro.so

============================================================================
WALLET CREDENTIALS (Keep these SECURE!)
============================================================================
Your Leather Wallet seed phrase (12 or 24 words)
WALLET_MNEMONIC="your twelve word seed phrase goes here"

Private key from Leather Wallet (64-character hex)
PRIVATE_KEY=your_64_character_hex_private_key_here

============================================================================
SMART CONTRACT IDS (Update after deployment)
============================================================================
PROPERTY_CONTRACT_ID=ST3BWHBBVPKWQ4KX0TC3BZ2GYG96F3RK8JC6ETXSC.propertyTokenizer
NFT_CONTRACT_ID=ST3BWHBBVPKWQ4KX0TC3BZ2GYG96F3RK8JC6ETXSC.NFTToken
ORACLE_CONTRACT_ID=ST3BWHBBVPKWQ4KX0TC3BZ2GYG96F3RK8JC6ETXSC.priceOracle

============================================================================
TRANSACTION SETTINGS
============================================================================
DEFAULT_FEE=10000 # in microSTX (10000 = 0.01 STX)
TX_TIMEOUT=300 # seconds
POST_CONDITION_MODE=allow

text

### 3. Get Testnet STX

Visit [Stacks Testnet Faucet](https://explorer.stacks.co/sandbox/faucet?chain=testnet) to request testnet STX for your wallet address.

### 4. Security Best Practices

Add .env to .gitignore
echo ".env" >> .gitignore

Set restrictive file permissions
chmod 600 .env

text

---

## 📜 Smart Contracts

### Contract Deployment

#### Local Testing with Clarinet

Initialize Clarinet project
clarinet integrate

Check syntax
clarinet check

Run unit tests
clarinet test

Start local devnet
clarinet devnet start

text

#### Deploy to Testnet

Using Clarinet
clarinet deploy --testnet

Or manually with Stacks CLI
stx deploy_contract propertyTokenizer ./contracts/propertyTokenizer.clar
--testnet --private-key YOUR_PRIVATE_KEY

text

### Contract Interactions

#### Read-Only Functions

// Get property information
const propInfo = await callReadOnlyFunction({
contractAddress: 'ST3B...',
contractName: 'propertyTokenizer',
functionName: 'get-property-info',
functionArgs: [stringAsciiCV('PROP-001')],
network: new StacksTestnet()
});

text

#### Write Functions

// Create new property
const tx = await makeContractCall({
contractAddress: 'ST3B...',
contractName: 'propertyTokenizer',
functionName: 'create-tokenized-property',
functionArgs: [
stringAsciiCV('PROP-001'),
stringAsciiCV('123 Main St'),
uintCV(10000000),
uintCV(100)
],
senderKey: PRIVATE_KEY,
network: new StacksTestnet()
});

text

---

## 👨‍💻 Developer Guide

### Project Structure

LedgerX/
├── contracts/
│ ├── propertyTokenizer.clar # Main tokenization logic
│ ├── NFTToken.clar # NFT implementation
│ └── priceOracle.clar # Oracle system
├── tests/
│ ├── propertyTokenizer.test.ts
│ ├── NFTToken.test.ts
│ └── priceOracle.test.ts
├── scripts/
│ ├── test-rwa.js # Integration test script
│ ├── deploy.js # Deployment script
│ └── validate-env.js # Environment validator
├── .env.example # Environment template
├── Clarinet.toml # Clarinet configuration
├── package.json
└── README.md

text

### Development Workflow

#### 1. **Setup Development Environment**

Install dependencies
npm install

Validate configuration
node scripts/validate-env.js

text

#### 2. **Write Clarity Contracts**

Use Clarity best practices:
- Use descriptive variable names
- Implement proper access controls
- Add extensive comments
- Follow naming conventions (kebab-case)

#### 3. **Test Locally**

Run Clarity unit tests
clarinet test

Run integration tests
node scripts/test-rwa.js

text

#### 4. **Deploy to Testnet**

Deploy contracts
clarinet deploy --testnet

Update .env with deployed contract IDs
text

#### 5. **Frontend Integration**

import { StacksTestnet } from '@stacks/network';
import { openContractCall } from '@stacks/connect';

// Call contract from frontend
await openContractCall({
network: new StacksTestnet(),
contractAddress: 'ST3B...',
contractName: 'propertyTokenizer',
functionName: 'buy-token',
functionArgs: [
stringAsciiCV('PROP-001'),
uintCV(0),
uintCV(100000)
]
});

text

### Clarity Development Tips

#### Data Structure Best Practices

;; Use descriptive map names
(define-map properties
{ property-id: (string-ascii 50) }
{
owner: principal,
property-address: (string-ascii 256),
total-value: uint,
total-tokens: uint,
tokens-sold: uint,
is-active: bool
}
)

text

#### Error Handling

;; Define clear error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PROPERTY-NOT-FOUND (err u101))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u102))

;; Use asserts for validation
(asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)

text

#### Gas Optimization

- Minimize storage reads
- Use `let` bindings for repeated values
- Batch operations when possible
- Optimize map lookups

---

## 🧪 Testing

### Unit Tests (Clarinet)

// tests/propertyTokenizer.test.ts
import { Clarinet, Tx, Chain, Account } from 'clarinet';

Clarinet.test({
name: "Can create tokenized property",
async fn(chain: Chain, accounts: Map<string, Account>) {
const deployer = accounts.get('deployer')!;

text
let block = chain.mineBlock([
  Tx.contractCall(
    'propertyTokenizer',
    'create-tokenized-property',
    [
      types.ascii('PROP-001'),
      types.ascii('123 Main St'),
      types.uint(10000000),
      types.uint(100)
    ],
    deployer.address
  )
]);

block.receipts.result.expectOk();
}
});

text

### Integration Tests (Node.js)

Run full integration test suite
node scripts/test-rwa.js

text

**Test Coverage:**
- Property creation
- Token minting
- Token buying/selling
- Price oracle submissions
- Property pause/resume
- Access control

### Test Output Example

==================================================
🏠 RWA Tokenization Test
Network: testnet
Account: ST1ABC...
Contract Principal: ST3BWHBB...
== 1) create-tokenized-property ==
-> calling propertyTokenizer.create-tokenized-property...
txid: 0x1234abcd...
confirmed: 0x1234abcd...

== 2) get-property-info ==
-> read-only propertyTokenizer.get-property-info(1 args)
property-info: {
"owner": "ST1ABC...",
"total-value": 10000000,
"total-tokens": 100,
"tokens-sold": 0
}

✅ == TESTS COMPLETE ==

text

---

## 🚢 Deployment

### Testnet Deployment

#### Step 1: Prepare Contracts

Verify contract syntax
clarinet check

Run tests
clarinet test

text

#### Step 2: Deploy

Deploy using Clarinet
clarinet deploy --testnet

Or use deployment script
node scripts/deploy.js

text

#### Step 3: Verify Deployment

Check contracts on [Stacks Explorer](https://explorer.stacks.co/?chain=testnet)

https://explorer.stacks.co/txid/[TRANSACTION_ID]?chain=testnet

text

#### Step 4: Update Configuration

Update `.env` with deployed contract addresses:

PROPERTY_CONTRACT_ID=ST3BWHBBVPKWQ4KX0TC3BZ2GYG96F3RK8JC6ETXSC.propertyTokenizer
NFT_CONTRACT_ID=ST3BWHBBVPKWQ4KX0TC3BZ2GYG96F3RK8JC6ETXSC.NFTToken
ORACLE_CONTRACT_ID=ST3BWHBBVPKWQ4KX0TC3BZ2GYG96F3RK8JC6ETXSC.priceOracle

text

### Mainnet Deployment

⚠️ **Before deploying to mainnet:**

1. Complete extensive testing on testnet
2. Perform security audit
3. Review all contract code
4. Test with real STX amounts on testnet
5. Prepare rollback strategy

Deploy to mainnet (use with caution)
clarinet deploy --mainnet

text

---

## 💡 Usage Examples

### Create a Property

const { makeContractCall } = require('@stacks/transactions');

// Create property
await makeContractCall({
contractAddress: CONTRACT_PRINCIPAL,
contractName: 'propertyTokenizer',
functionName: 'create-tokenized-property',
functionArgs: [
stringAsciiCV('PROP-NYC-001'),
stringAsciiCV('456 Park Avenue, New York'),
uintCV(50000000), // $500k in cents
uintCV(500) // 500 tokens
],
senderKey: PRIVATE_KEY,
network: new StacksTestnet()
});

text

### Mint NFT Tokens

// Mint 100 tokens for the property
await makeContractCall({
contractAddress: CONTRACT_PRINCIPAL,
contractName: 'NFTToken',
functionName: 'mint-property-tokens',
functionArgs: [
stringAsciiCV('PROP-NYC-001'),
stringAsciiCV('456 Park Avenue, New York'),
uintCV(100),
principalCV(OWNER_ADDRESS)
],
senderKey: PRIVATE_KEY,
network: new StacksTestnet()
});

text

### Buy a Token

// Buy token index 0 of property
await makeContractCall({
contractAddress: CONTRACT_PRINCIPAL,
contractName: 'propertyTokenizer',
functionName: 'buy-token',
functionArgs: [
stringAsciiCV('PROP-NYC-001'),
uintCV(0), // token index
uintCV(1000) // payment in cents
],
senderKey: BUYER_PRIVATE_KEY,
network: new StacksTestnet()
});

text

### Submit Oracle Price Feed

// Oracle submits property valuation
await makeContractCall({
contractAddress: CONTRACT_PRINCIPAL,
contractName: 'priceOracle',
functionName: 'submit-price-feed',
functionArgs: [
stringAsciiCV('PROP-NYC-001'),
uintCV(51000000), // new valuation
uintCV(9500), // confidence (95%)
stringAsciiCV('zillow-api'),
stringAsciiCV('valuation'),
stringAsciiCV('metadata')
],
senderKey: ORACLE_PRIVATE_KEY,
network: new StacksTestnet()
});

text

---

## 📚 API Reference

### propertyTokenizer Contract

#### Read-Only Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `get-property-info` | `property-id: string-ascii` | Property details | Retrieve property information |
| `get-current-price` | `property-id: string-ascii` | `uint` | Get current token price |
| `get-token-owner` | `property-id, token-index` | `principal` | Get token owner |

#### Public Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `create-tokenized-property` | `property-id, address, value, tokens` | `(ok bool)` | Create new property |
| `buy-token` | `property-id, token-index, payment` | `(ok bool)` | Purchase token |
| `pause-property` | `property-id` | `(ok bool)` | Pause property trading |
| `resume-property` | `property-id` | `(ok bool)` | Resume property trading |

### NFTToken Contract

#### Read-Only Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `get-owner` | `token-id: tuple` | `principal` | Get NFT owner |
| `get-token-uri` | `token-id: tuple` | `string-ascii` | Get token metadata URI |

#### Public Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `mint-property-tokens` | `property-id, address, count, recipient` | `(ok bool)` | Mint NFT tokens |
| `transfer` | `token-id, sender, recipient` | `(ok bool)` | Transfer NFT |
| `record-purchase` | `token-id, buyer, seller, price` | `(ok bool)` | Record transaction |

### priceOracle Contract

#### Read-Only Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `get-aggregated-price` | `property-id: string-ascii` | Price data | Get consensus price |
| `get-oracle-info` | `oracle: principal` | Oracle details | Get oracle information |

#### Public Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `register-oracle` | `oracle, stake, category, region` | `(ok bool)` | Register oracle provider |
| `submit-price-feed` | `property-id, price, confidence, ...` | `(ok bool)` | Submit price data |
| `update-market-indicator` | `asset-class, region, value, ...` | `(ok bool)` | Update market metrics |

---

## 🔧 Troubleshooting

### Common Issues

#### 1. **Authentication Failed Error**

Error: Authentication failed for 'https://github.com/...'

text

**Solution:**
- Generate GitHub Personal Access Token
- Use token instead of password
- Or use SSH authentication

#### 2. **Cannot Set Properties of Undefined**

TypeError: Cannot set properties of undefined (setting 'coreApiUrl')

text

**Solution:**
// Change from:
const network = StacksTestnet;

// To:
const network = new StacksTestnet();

text

#### 3. **Transaction Timeout**

Error: Timeout waiting for tx 0x...

text

**Solution:**
- Increase `TX_TIMEOUT` in `.env`
- Check testnet status at [status.hiro.so](https://status.hiro.so)
- Verify sufficient STX balance for fees

#### 4. **Contract Not Found**

Error: Contract not found: ST3B....propertyTokenizer

text

**Solution:**
- Verify contract is deployed
- Check contract ID in `.env` matches deployment
- Confirm using correct network (testnet/mainnet)

#### 5. **Insufficient Balance**

Error: Insufficient balance

text

**Solution:**
- Request testnet STX from faucet
- Wait for faucet transaction to confirm
- Check balance: `stx balance ADDRESS --testnet`

---

## 🗺️ Roadmap

### Phase 1: Core Features (Current)
- ✅ Property tokenization
- ✅ NFT minting system
- ✅ Oracle price feeds
- ✅ Basic trading functionality

### Phase 2: Enhanced Features (Q1 2026)
- [ ] Secondary marketplace
- [ ] Automated dividend distributions
- [ ] Multi-signature property management
- [ ] Enhanced oracle network

### Phase 3: Scale & Optimize (Q2 2026)
- [ ] Gas optimization
- [ ] Batch operations
- [ ] Layer 2 scaling solutions
- [ ] Cross-chain bridges

### Phase 4: Enterprise Features (Q3 2026)
- [ ] KYC/AML integration
- [ ] Compliance modules
- [ ] Institutional dashboard
- [ ] Legal document automation

### Phase 5: Ecosystem (Q4 2026)
- [ ] Property insurance integration
- [ ] Lending/borrowing protocols
- [ ] Mobile applications
- [ ] Analytics platform

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Getting Started

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feat/amazing-feature`)
5. Open a Pull Request

### Commit Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Test additions/changes
- `chore:` Build process or auxiliary tool changes

### Code Standards

- Follow Clarity style guide
- Add unit tests for new features
- Update documentation
- Ensure all tests pass
- Use descriptive variable names

### Pull Request Process

1. Update README.md with new features
2. Add tests covering your changes
3. Ensure CI/CD pipeline passes
4. Request review from maintainers
5. Address review feedback

---

## 📞 Contact & Support

- **Project Link**: https://github.com/jbhavya876/LedgerX
- **Issues**: https://github.com/jbhavya876/LedgerX/issues
- **Discussions**: https://github.com/jbhavya876/LedgerX/discussions

### Resources

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language](https://clarity-lang.org/)
- [Hiro Platform](https://platform.hiro.so/)
- [Stacks Discord](https://discord.gg/stacks)

---

## 🙏 Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Hiro Systems for development tools
- Bitcoin community for foundational security
- Open-source contributors

---

**Built with ❤️ on Stacks | Secured by Bitcoin**

---
