## Install environment.

Change **.env.example** to **.env** and add **PRIVATE_KEY** and **BSC_API_KEY**.

Install node modules.

```bash
npm i
```

## Test on local network.

Convert **daySeconds** as **1**

```bash
uint256 private constant daySeconds = 1;
```

```bash
npx hardhat test
```

## Deploy to test net.

Convert **daySeconds** as **86400**

```bash
uint256 private constant daySeconds = 86400;
```

```bash
npx hardhat run scripts/deploy.js --network testnet
```

## Deploy to main net.

Convert **daySeconds** as **86400**

```bash
uint256 private constant daySeconds = 86400;
```

```bash
npx hardhat run scripts/deploy.js --network mainnet
```

