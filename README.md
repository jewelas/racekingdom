## Install environment.

Change **.env.example** to **.env** and add **PRIVATE_KEY** and **BSC_API_KEY**.

Install node modules.

```bash
npm i
```

## Deploy to test net.

```bash
npx hardhat run scripts/deploy.js --network testnet
```

## Deploy to main net.

```bash
npx hardhat run scripts/deploy.js --network mainnet
```

## Test on local network.

```bash
npx hardhat test
```