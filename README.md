<div align="center">

# 🏠 LedgerX - Real Estate Tokenization Platform

[![Stacks](https://img.shields.io/badge/Built%20on-Stacks-5546FF?style=for-the-badge&logo=stacks&logoColor=white)](https://www.stacks.co/)
[![Clarity](https://img.shields.io/badge/Smart%20Contracts-Clarity-purple?style=for-the-badge)](https://clarity-lang.org/)
[![Bitcoin](https://img.shields.io/badge/Secured%20by-Bitcoin-F7931A?style=for-the-badge&logo=bitcoin&logoColor=white)](https://bitcoin.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)

**A decentralized platform built on Stacks blockchain that enables fractional property ownership through NFT-based tokenization, lowering investment barriers and providing liquidity to real estate assets.**

[Features](#-key-features) • [Quick Start](#-quick-start) • [Documentation](#-api-reference) • [Contributing](#-contributing)

</div>

---

## 📖 Table of Contents

- [Core Problem & Solution](#-core-problem--solution)
- [Key Features](#-key-features)
- [Smart Contract Architecture](#️-smart-contract-architecture)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Usage Examples](#-usage-examples)
- [Project Structure](#-project-structure)
- [API Reference](#-api-reference)
- [Testing](#-testing)
- [Roadmap](#️-roadmap)
- [Technology Stack](#️-technology-stack)
- [Contributing](#-contributing)
- [Resources](#-resources)

---

## 🎯 Core Problem & Solution

### Problem

Traditional real estate requires **large capital investments** and suffers from **illiquidity**, limiting accessibility for most investors.

### Solution

LedgerX tokenizes physical properties into fractional NFTs, enabling:

| Feature | Description |
|---------|-------------|
| **Fractional Ownership** | Purchase property shares starting from minimal investments |
| **Enhanced Liquidity** | Trade property tokens on secondary markets |
| **Transparent Pricing** | Real-time valuation via decentralized oracles |
| **Bitcoin Security** | Inherit Bitcoin's security through Stacks Layer 2 |

---

## ⚡ Key Features

### 1. Property Tokenization
✅ Create tokenized properties with unique identifiers  
✅ Define total value and token supply  
✅ Automatic price-per-token calculation  
✅ Property metadata storage (address, valuation, status)

### 2. Fractional NFT System
✅ Mint property-backed NFT tokens representing ownership shares  
✅ Unique token IDs combining property ID + token index  
✅ ERC-721-compatible structure with property linkage

### 3. Decentralized Trading
✅ Peer-to-peer token buying and selling  
✅ Dynamic market-based pricing  
✅ Automatic price discovery mechanism  
✅ Complete transaction history tracking

### 4. Oracle Price Feeds
✅ Real-time property valuation from registered oracles  
✅ Multi-oracle consensus mechanism  
✅ Confidence-weighted price aggregation

### 5. Governance & Control
✅ Property owner controls (pause/resume trading)  
✅ Oracle registration and stake management  
✅ Access control for administrative functions

---

## 🏗️ Smart Contract Architecture

### Contract 1: `propertyTokenizer.clar`

**Core contract managing property lifecycle and token economics**

#### Key Functions

| Function | Description |
|----------|-------------|
| `create-tokenized-property` | Initialize new property |
| `buy-token` | Purchase property token |
| `get-current-price` | Retrieve latest token price |
| `pause-property` / `resume-property` | Trading controls |

#### Data Structures

| Map | Purpose |
|-----|---------|
| `properties` | Property details (owner, address, value, tokens) |
| `token-ownership` | Token ownership per property |
| `price-history` | Historical token prices |

---

### Contract 2: `NFTToken.clar`

**NFT implementation for property-backed tokens**

#### Key Functions

| Function | Description |
|----------|-------------|
| `mint-property-tokens` | Batch mint tokens for a property |
| `transfer` | Transfer NFT ownership |
| `get-owner` | Query token owner |
| `get-token-uri` | Retrieve token metadata |

#### Data Structures

| Map | Purpose |
|-----|---------|
| `token-data` | NFT metadata (property-id, token-index) |
| `token-uris` | Token metadata URIs |
| `nft-ownership` | Current NFT owners |

---

### Contract 3: `priceOracle.clar`

**Decentralized oracle system for property valuation**

#### Key Functions

| Function | Description |
|----------|-------------|
| `register-oracle` | Add new oracle provider |
| `submit-price-feed` | Oracle submits property valuation |
| `get-aggregated-price` | Calculate consensus price |
| `update-market-indicator` | Update macro market trends |

#### Data Structures

| Map | Purpose |
|-----|---------|
| `oracles` | Registered oracle providers |
| `price-feeds` | Oracle-submitted prices |
| `market-indicators` | Market trend tracking |

---

## 📋 Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| **Node.js** | ≥ 18.x | Runtime environment |
| **npm/yarn** | Latest | Package manager |
| **Clarinet** | ≥ 2.0 | Clarity development environment |
| **Git** | Latest | Version control |
| **Leather Wallet** | Latest | Stacks wallet (browser extension) |

---

## 🚀 Quick Start

### Step 1: Clone Repository
git clone https://github.com/jbhavya876/LedgerX.git
cd LedgerX

### Step 2: Install Dependencies
npm install

**Core Dependencies:**
{
"@stacks/transactions": "^6.x",
"@stacks/network": "^6.x",
"dotenv": "^16.x"
}


### Step 3: Install Clarinet
macOS/Linux
brew install clarinet

Windows
winget install clarinet


### Step 4: Configure Environment
cp .env.example .env

**Update .env:**
Network Configuration
NETWORK=testnet
WALLET_MNEMONIC="your twelve word seed phrase"
PRIVATE_KEY=your_64_character_hex_private_key

Smart Contract IDs (Update after deployment)
PROPERTY_CONTRACT_ID=ST3BWHBB...propertyTokenizer
NFT_CONTRACT_ID=ST3BWHBB...NFTToken
ORACLE_CONTRACT_ID=ST3BWHBB...priceOracle

### Step 5: Test Locally
Check syntax
clarinet check

Run unit tests
clarinet test

Start local devnet
clarinet devnet start


### Step 6: Deploy to Testnet
clarinet deploy --testnet
---

## 💡 Usage Examples

### Example 1: Create a Property

Create a new tokenized property with unique ID, address, total value, and token supply.

await makeContractCall({
contractAddress: CONTRACT_PRINCIPAL,
contractName: 'propertyTokenizer',
functionName: 'create-tokenized-property',
functionArgs: [
stringAsciiCV('PROP-NYC-001'), // Property ID
stringAsciiCV('456 Park Avenue, New York'), // Address
uintCV(50000000), // $500k in cents
uintCV(500) // 500 tokens
],
senderKey: PRIVATE_KEY,
network: new StacksTestnet()
});

text

**Parameters:**
- `property-id`: Unique identifier (e.g., 'PROP-NYC-001')
- `address`: Physical property address
- `total-value`: Property value in cents
- `token-supply`: Number of fractional tokens

---

### Example 2: Mint NFT Tokens

Mint NFT tokens for a property and assign them to the owner.

await makeContractCall({
contractAddress: CONTRACT_PRINCIPAL,
contractName: 'NFTToken',
functionName: 'mint-property-tokens',
functionArgs: [
stringAsciiCV('PROP-NYC-001'),
stringAsciiCV('456 Park Avenue, New York'),
uintCV(100), // Number of tokens to mint
principalCV(OWNER_ADDRESS) // Owner's Stacks address
],
senderKey: PRIVATE_KEY,
network: new StacksTestnet()
});

text

**Returns:** Transaction ID for the minting operation

---

### Example 3: Buy a Token

Purchase a specific property token by index.

await makeContractCall({
contractAddress: CONTRACT_PRINCIPAL,
contractName: 'propertyTokenizer',
functionName: 'buy-token',
functionArgs: [
stringAsciiCV('PROP-NYC-001'), // Property ID
uintCV(0), // Token index (0-based)
uintCV(1000) // Payment in cents
],
senderKey: BUYER_PRIVATE_KEY,
network: new StacksTestnet()
});

text

**Requirements:**
- Buyer must have sufficient STX balance
- Token must be available for purchase
- Property must be active (not paused)

---

### Example 4: Submit Oracle Price Feed

Oracle providers submit property valuations with confidence scores.

await makeContractCall({
contractAddress: CONTRACT_PRINCIPAL,
contractName: 'priceOracle',
functionName: 'submit-price-feed',
functionArgs: [
stringAsciiCV('PROP-NYC-001'), // Property ID
uintCV(51000000), // New valuation ($510k)
uintCV(9500), // Confidence score (95%)
stringAsciiCV('zillow-api'), // Data source
stringAsciiCV('valuation'), // Feed type
stringAsciiCV('metadata') // Additional metadata
],
senderKey: ORACLE_PRIVATE_KEY,
network: new StacksTestnet()
});

text

**Oracle Requirements:**
- Must be registered as an oracle
- Must have staked minimum required amount
- Confidence score between 0-10000 (basis points)


## 📁 Project Structure

<pre>
LedgerX/
│
├── contracts/
│   ├── propertyTokenizer.clar    # Main tokenization logic
│   ├── NFTToken.clar              # NFT implementation
│   └── priceOracle.clar           # Oracle system
│
├── tests/
│   ├── propertyTokenizer.test.ts
│   ├── NFTToken.test.ts
│   └── priceOracle.test.ts
│
├── scripts/
│   ├── test-rwa.js                # Integration tests
│   ├── deploy.js                  # Deployment script
│   └── validate-env.js            # Environment validator
│
├── .env.example                   # Environment template
├── Clarinet.toml                  # Clarinet configuration
├── package.json                   # Node dependencies
├── package-lock.json
├── LICENSE
└── README.md
</pre>

## 🔧 API Reference

### propertyTokenizer Contract

#### Read-Only Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `get-property-info` | `property-id` | Property details | Retrieve property information |
| `get-current-price` | `property-id` | `uint` | Get current token price |
| `get-token-owner` | `property-id, token-index` | `principal` | Get token owner |

#### Public Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `create-tokenized-property` | `property-id, address, value, tokens` | `(ok bool)` | Create new property |
| `buy-token` | `property-id, token-index, payment` | `(ok bool)` | Purchase token |
| `pause-property` | `property-id` | `(ok bool)` | Pause trading |
| `resume-property` | `property-id` | `(ok bool)` | Resume trading |

---

### NFTToken Contract

#### Read-Only Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `get-owner` | `token-id` | `principal` | Get NFT owner |
| `get-token-uri` | `token-id` | `string-ascii` | Get metadata URI |

#### Public Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `mint-property-tokens` | `property-id, address, count, recipient` | `(ok bool)` | Mint NFTs |
| `transfer` | `token-id, sender, recipient` | `(ok bool)` | Transfer NFT |
| `record-purchase` | `token-id, buyer, seller, price` | `(ok bool)` | Record transaction |

---

### priceOracle Contract

#### Read-Only Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `get-aggregated-price` | `property-id` | Price data | Get consensus price |
| `get-oracle-info` | `oracle` | Oracle details | Get oracle information |

#### Public Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `register-oracle` | `oracle, stake, category, region` | `(ok bool)` | Register oracle |
| `submit-price-feed` | `property-id, price, confidence, ...` | `(ok bool)` | Submit price |
| `update-market-indicator` | `asset-class, region, value, ...` | `(ok bool)` | Update metrics |

---

## 🧪 Testing

### Run Unit Tests
clarinet test

### Run Integration Tests
node scripts/test-rwa.js

### Test Coverage

| Test Category | Status |
|---------------|--------|
| Property creation | ✅ |
| Token minting | ✅ |
| Token buying/selling | ✅ |
| Price oracle submissions | ✅ |
| Property pause/resume | ✅ |
| Access control | ✅ |

---

## 🗺️ Roadmap

### Phase 1: Core Features (Current)
- ✅ Property tokenization
- ✅ NFT minting system
- ✅ Oracle price feeds
- ✅ Basic trading functionality

### Phase 2: Enhanced Features (Q1 2026)
- 🔄 Secondary marketplace
- 🔄 Automated dividend distributions
- 🔄 Multi-signature property management
- 🔄 Enhanced oracle network

### Phase 3: Scale & Optimize (Q2 2026)
- 🔜 Gas optimization
- 🔜 Batch operations
- 🔜 Cross-chain bridges

### Phase 4: Enterprise Features (Q3 2026)
- 🔜 KYC/AML integration
- 🔜 Compliance modules
- 🔜 Institutional dashboard

---

## 🛠️ Technology Stack

| Category | Technology |
|----------|------------|
| **Blockchain** | Stacks (Bitcoin Layer 2) |
| **Smart Contract Language** | Clarity |
| **Development Framework** | Clarinet |
| **JavaScript Libraries** | @stacks/transactions, @stacks/network |
| **Wallet** | Leather Wallet |
| **Network** | Stacks Testnet/Mainnet |

---

## 🤝 Contributing

### How to Contribute

1. Fork the repository
2. Create a feature branch
   git checkout -b feat/amazing-feature

3. Commit changes
   git commit -m 'feat: add amazing feature'

4. Push to branch
   git push origin feat/amazing-feature

5. Open a Pull Request

### Commit Convention

| Type | Description |
|------|-------------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `docs:` | Documentation changes |
| `refactor:` | Code refactoring |
| `test:` | Test additions/changes |

---

## 📞 Resources

| Resource | Link |
|----------|------|
| **GitHub** | [https://github.com/jbhavya876/LedgerX](https://github.com/jbhavya876/LedgerX) |
| **Stacks Docs** | [https://docs.stacks.co](https://docs.stacks.co/) |
| **Clarity Language** | [https://clarity-lang.org](https://clarity-lang.org/) |
| **Hiro Platform** | [https://www.hiro.so](https://www.hiro.so/) |

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

---

<div align="center">

**Built with ❤️ on Stacks | Secured by Bitcoin**

[![GitHub](https://img.shields.io/badge/GitHub-jbhavya876-181717?style=flat-square&logo=github)](https://github.com/jbhavya876/LedgerX)
[![Stacks](https://img.shields.io/badge/Stacks-5546FF?style=flat-square&logo=stacks)](https://www.stacks.co/)
[![Bitcoin](https://img.shields.io/badge/Bitcoin-F7931A?style=flat-square&logo=bitcoin)](https://bitcoin.org/)

**Developed by [Bhavya Jain](https://github.com/jbhavya876)**

[⬆ Back to Top](#-ledgerx---real-estate-tokenization-platform)

</div>
   
