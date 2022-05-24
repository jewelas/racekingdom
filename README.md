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

Convert **daySeconds** as **86400** in **RKStaking.sol**

```bash
uint256 private constant daySeconds = 86400;
```

run deployment script.

```bash
npm run deployTestnet
```

## Deploy to main net.

Convert **daySeconds** as **86400** in **RKSTaking.sol**

```bash
uint256 private constant daySeconds = 86400;
```

run deployment script.

```bash
npm run deployMainnet
```

