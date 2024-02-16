# Hospital Cash Smart Contract

This project demonstrates a basic Health Insurance Smart Contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run --network localhost scripts/deploy.ts
```

## Run a local development network
See: [Metamask Documentation - Run a development network](https://docs.metamask.io/wallet/how-to/get-started-building/run-devnet/)

Create a new Meta Mask account on your iPhone and create a recovery phrase.

Add a .env File in the main directory. Make sure you do not check them in.

Add the following entry in .env with your phrase:
```
SEED_PHRASE=auto book read ...
```

Determine your IP address e.g. via ifconfig. 
Execute the following command.
```
 npx hardhat node --hostname 0.0.0.0
 ```

In the Meta-Mask App:
- Select the network at the top 
- Add network
- Add a network manually
- Add a custom name
- Enter your IP address with port as the RPC URL. e.g.: https://192.168.178.86:8545/
- Enter as Chain-Id: 1337
- Now you can add a new Wallet 
- Now you can add a new wallet / account

## Deployment
npx hardhat run --network localhost scripts/deploy.ts