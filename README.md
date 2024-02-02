# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```

## Testing Local
See: https://docs.metamask.io/wallet/how-to/get-started-building/run-devnet/

Create a new Meta Mask account on your iPhone and create a recovery phrase.

Add a .env File in the main directory. Make sure you do not check them in.

Füge folgenden Eintrag in .env mit deiner Phrase ein:
```
SEED_PHRASE=auto book read ...
```

Determine your IP address e.g. via ifconfig. 
Execute the following command with your IP address.
```
 npx hardhat node --hostname 192.168.0.3
 ```

In the Meta-Mask App:
- Select the network at the top 
- Add network
- Add a network manually
- Add a custom name
- Enter your IP address with port as the RPC URL. e.g.: https://192.168.0.3:8545/
- Enter as Chain-Id: 1337
- Now you can add a new Wallet 
- Now you can add a new wallet / account