import { ethers } from "hardhat";

async function main() {
  const HospitalCash = await ethers.deployContract("HospitalCash");

  await HospitalCash.waitForDeployment();

  console.log(`HealthContract deployed to ${HospitalCash.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
