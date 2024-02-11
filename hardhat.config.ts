import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from 'dotenv'; 

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    hardhat: {
      accounts: {
        mnemonic: process.env.SEED_PHRASE
      },
      chainId: 1337,
    }
  }
};

export default config;
