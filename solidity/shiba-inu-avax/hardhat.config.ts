import { task } from "hardhat/config";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber } from "ethers";
import "dotenv/config";
import "@nomiclabs/hardhat-waffle";

const PRIVATE_KEY = process.env.TESTNET_PRIVATE_KEY;

task("accounts", "Prints the list of accounts", async (args, hre): Promise<void> => {
  const accounts: SignerWithAddress[] = await hre.ethers.getSigners();
  accounts.forEach((account: SignerWithAddress): void => {
    console.log(account.address);
  });
});

task("balances", "Prints the list of AVAX account balances", async (args, hre): Promise<void> => {
  const accounts: SignerWithAddress[] = await hre.ethers.getSigners();
  for (const account of accounts) {
    const balance: BigNumber = await hre.ethers.provider.getBalance(
      account.address
    );
    console.log(`${account.address}: ${balance.toString()}`);
  }
});

export default {
  solidity: "0.8.9",
  networks: {
    fuji: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      gasPrice: 225000000000,
      chainId: 43113,
      // Use only testnet accounts
      accounts: [
        `${PRIVATE_KEY}`,
      ],
    },
  },
};
