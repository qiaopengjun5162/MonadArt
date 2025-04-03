# MonaPunk NFT Project

MonaPunk Banner

**MonaPunk** is an NFT project built on the Monad blockchain, an Ethereum-compatible Layer-1 blockchain with 10,000 TPS, 500ms block frequency, and 1s finality. This project leverages OpenZeppelin's ERC721 standard to create, manage, and trade NFTs with features like minting, burning, pausing, and enumeration. The contract is secure, extensible, and compatible with marketplaces like OpenSea.

## Table of Contents

- Features (#features)
- Getting Started (#getting-started)
  - Prerequisites (#prerequisites)
  - Installation (#installation)
- Usage (#usage)
  - Deploying the Contract (#deploying-the-contract)
  - Minting NFTs (#minting-nfts)
  - Verifying the Contract (#verifying-the-contract)
- Contract Details (#contract-details)
- File Structure (#file-structure)
- Testing (#testing)
- Test Coverage (#test-coverage)
- Contributing (#contributing)
- License (#license)
- References (#references)

## Features

- **ERC721 Compliance**: Fully compliant with the ERC721 standard for NFTs.
- **Minting**: Securely mint NFTs with custom metadata URIs.
- **Burnable**: Allows token owners to burn their NFTs.
- **Pausable**: Contract owner can pause/unpause the contract for emergency situations.
- **Enumerable**: Easily query all tokens or tokens owned by an address.
- **URI Storage**: Supports metadata storage for NFT attributes (e.g., name, description, image).
- **Ownable**: Restricted functions for the contract owner (e.g., minting, pausing).
- **Metadata Example**: Includes a sample metadata file (docs/monaPunk.json) for reference.
- **Monad Compatibility**: Deployed on the Monad testnet for high-performance transactions.

## Getting Started

### Prerequisites

To work with this project, you'll need the following tools:

- [Foundry](https://getfoundry.sh/): A fast Ethereum development toolkit.
- [Node.js](https://nodejs.org/) (optional, for additional scripts or tools).
- [Solidity](https://soliditylang.org/) compiler (version ^0.8.22).
- An Ethereum wallet (e.g., MetaMask) for deployment and interaction.
- Access to a Monad node (e.g., via <https://testnet-rpc.monad.xyz>).

### Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/qiaopengjun5162/MonadArt.git
   cd MonadArt
   ```

2. **Install Foundry** (if not already installed):

   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

3. **Disable Foundry Nightly Warning** (optional):

   ```bash
   export FOUNDRY_DISABLE_NIGHTLY_WARNING=1
   ```

4. **Install Dependencies**: The project uses OpenZeppelin contracts. Foundry will automatically handle dependencies defined in remappings.txt and foundry.toml. Run:

   ```bash
   forge install
   ```

5. **Build the Project**: Compile the smart contracts:

   ```bash
   forge build
   ```

## Usage

### Deploying the Contract

1. **Import Your Wallet**: Import your private key into Foundry's wallet system:

   ```bash
   cast wallet import MetaMask --interactive
   ```

   Then, check the address:

   ```bash
   cast wallet address --account MetaMask
   ```

2. **Deploy the Contract**: Deploy the MonaPunk contract to the Monad testnet:

   ```bash
   forge create src/MonaPunk.sol:MonaPunk --account MetaMask --broadcast --constructor-args $ACCOUNT_ADDRESS --rpc-url https://testnet-rpc.monad.xyz
   ```

   - Replace $ACCOUNT_ADDRESS with the initial owner address.

   - Example output:

     ```text
     Deployer: 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
     Deployed to: 0x0660c412bf2aca856ee119cEfdD155b24595a6CE
     Transaction hash: 0x3b16fb11a783efef75a29d8819fced05ca769787f36784dabf2252ecfe12c630
     ```

   - View the transaction on Monad Explorer: [Transaction Link](https://testnet.monadexplorer.com/tx/0x3b16fb11a783efef75a29d8819fced05ca769787f36784dabf2252ecfe12c630)

   - View the contract: [Contract Link](https://testnet.monadexplorer.com/address/0x0660c412bf2aca856ee119cEfdD155b24595a6CE?tab=Contract)

### Minting NFTs

1. **Prepare Metadata**: Ensure your NFT metadata is hosted (e.g., on IPFS). An example metadata file (docs/monaPunk.json) is provided:

   json

   ```json
   {
     "name": "Whisper of the Horizon #001",
     "description": "A serene sunset capturing the fleeting moment of a plane's contrail slicing through the sky, framed by the silhouettes of barren trees. A perfect blend of nature and human presence.",
     "image": "ipfs://QmXyz123.../whisper-of-the-horizon-001.jpg",
     "external_url": "https://yourprojectwebsite.com/nft/whisper-of-the-horizon-001",
     "attributes": [
       { "trait_type": "Scene", "value": "Sunset" },
       { "trait_type": "Rarity", "value": "Rare" },
       { "trait_type": "Element", "value": "Sky" },
       { "trait_type": "Color Palette", "value": "Warm Orange to Cool Gray" },
       { "trait_type": "Mood", "value": "Calm" },
       { "trait_type": "Contrail Visibility", "value": "High", "max_value": 100 }
     ],
     "background_color": "FF8C42",
     "collection": {
       "name": "Skyward Silhouettes",
       "family": "Nature Art"
     }
   }
   ```

2. **Mint an NFT**: Use the safeMint function to mint an NFT. This can be done via a script or directly interacting with the contract on Monad Explorer:

   - Example transaction: [Mint Transaction](https://testnet.monadexplorer.com/tx/0x518d562e29631e74eed163206c690df8a32316483573067248848e6403c436c3)
   - View the minted NFT: [NFT Metadata](https://testnet.monadexplorer.com/nft/0x0660c412bf2aca856ee119cEfdD155b24595a6CE/0?tab=Metadata)

### Verifying the Contract

1. **Go to Monad Explorer**: Navigate to the contract verification page: [Verify Code](https://testnet.monadexplorer.com/verify-contract?address=0x0660c412bf2aca856ee119cEfdD155b24595a6CE).

2. **Run Verification Command**: Verify the contract using Foundry and Sourcify:

   bash

   ```bash
   forge verify-contract \
     --rpc-url https://testnet-rpc.monad.xyz \
     --verifier sourcify \
     --verifier-url 'https://sourcify-api-monad.blockvision.org' \
     0x0660c412bf2aca856ee119cEfdD155b24595a6CE \
     src/MonaPunk.sol:MonaPunk
   ```

   - Example output:

     ```text
     Contract successfully verified
     ```

   - View the verified contract: [Verified Contract](https://testnet.monadexplorer.com/address/0x0660c412bf2aca856ee119cEfdD155b24595a6CE?tab=Contract)

## Contract Details

The MonaPunk contract is an ERC721-based NFT contract with the following features:

- **Inheritance**:
  - ERC721: Core NFT functionality.
  - ERC721Burnable: Allows burning of NFTs.
  - ERC721Enumerable: Enables token enumeration.
  - ERC721Pausable: Adds pausing functionality.
  - ERC721URIStorage: Stores token metadata URIs.
  - Ownable: Restricts certain functions to the contract owner.
- **Key Functions**:
  - safeMint(address to, string memory uri): Mints a new NFT and sets its metadata URI (onlyOwner).
  - pause(): Pauses the contract (onlyOwner).
  - unpause(): Unpauses the contract (onlyOwner).
  - burn(uint256 tokenId): Burns an NFT (requires ownership or approval).
  - tokenURI(uint256 tokenId): Returns the metadata URI for a given token.
- **Deployment**:
  - Deployed on Monad testnet at: [0x0660c412bf2aca856ee119cEfdD155b24595a6CE](https://testnet.monadexplorer.com/address/0x0660c412bf2aca856ee119cEfdD155b24595a6CE).

## File Structure

```text
.
├── CHANGELOG.md           # Project changelog
├── LICENSE               # MIT License
├── README.md             # Project documentation
├── _typos.toml           # Typos configuration
├── cliff.toml            # Configuration for changelog generation
├── foundry.toml          # Foundry configuration
├── remappings.txt        # Dependency remappings
├── script/               # Deployment scripts
│   ├── MonaPunk.s.sol    # Deployment script for MonaPunk
│   └── deploy.sh         # Shell script for deployment
├── slither.config.json   # Slither static analysis configuration
├── src/                  # Source code
│   └── MonaPunk.sol      # MonaPunk NFT contract
├── style_guide.md        # Code style guide
├── test/                 # Test files
│   └── MonaPunk.t.sol    # Test suite for MonaPunk
└── docs/                 # Documentation and assets
    ├── MonaPunk.jpg      # Project banner
    └── monaPunk.json     # Sample NFT metadata
```

### Testing

Run the test suite to ensure the contract works as expected:

```bash
forge test --match-path test/MonaPunk.t.sol --show-progress -vv
```

- **Test Results**:
  - 21 tests passed, 0 failed, 0 skipped.
  - Total runtime: 5.68s (3.91s CPU time).
  - Example tests:
    - test_SafeMint(): Verifies minting functionality.
    - test_Pause(): Tests pausing functionality.
    - test_Burn(): Ensures burning works correctly.
    - test_Enumerable(): Validates token enumeration.

### Test Coverage

Generate a test coverage report to evaluate the quality of the test suite:

```bash
forge coverage --match-path test/MonaPunk.t.sol --report lcov
genhtml lcov.info -o coverage
```

- **Coverage Results**:

  ```text
  | File                  | % Lines        | % Statements   | % Branches    | % Funcs      |
  |-----------------------|----------------|----------------|---------------|--------------|
  | script/MonaPunk.s.sol | 0.00% (0/9)    | 0.00% (0/9)    | 100.00% (0/0) | 0.00% (0/2)  |
  | src/MonaPunk.sol      | 88.24% (15/17) | 92.86% (13/14) | 100.00% (0/0) | 85.71% (6/7) |
  | Total                 | 57.69% (15/26) | 56.52% (13/23) | 100.00% (0/0) | 66.67% (6/9) |
  ```

- Open coverage/index.html in your browser to view the detailed report.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch (git checkout -b feature/your-feature).
3. Make your changes and commit (git commit -m "Add your feature").
4. Push to your branch (git push origin feature/your-feature).
5. Open a pull request.

Please follow the style guide (style_guide.md) and ensure all tests pass before submitting.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## References

- [OpenZeppelin Contracts](https://www.openzeppelin.com/solidity-contracts)
- [OpenZeppelin GitHub](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [EIP-721: ERC721 Standard](https://eips.ethereum.org/EIPS/eip-721)
- [Monad Official Website](https://www.monad.xyz/)
- [Monad Developer Docs](https://docs.monad.xyz/introduction/monad-for-developers)
- [Monad Network Information](https://docs.monad.xyz/developer-essentials/network-information)
- [Monad Testnet Explorer](https://testnet.monadexplorer.com/)
- [Foundry on Monad](https://github.com/monad-developers/foundry-monad)
- [Deployed Contract](https://testnet.monadexplorer.com/address/0x0660c412bf2aca856ee119cEfdD155b24595a6CE)
- [Deployment Transaction](https://testnet.monadexplorer.com/tx/0x3b16fb11a783efef75a29d8819fced05ca769787f36784dabf2252ecfe12c630)
- [Scaffold-ETH on Monad](https://docs.monad.xyz/guides/scaffold-eth-monad)
- [Project Repository](https://github.com/qiaopengjun5162/MonadArt)
