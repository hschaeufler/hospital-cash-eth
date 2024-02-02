import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from 'dotenv'; 

dotenv.config();

const MNEMONIC = process.env.SEED_PHRASE
console.log(MNEMONIC) 

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
      accounts: {
        mnemonic: process.env.SEED_PHRASE
      },
      chainId: 1337,
    }
  }
};

export default config;
