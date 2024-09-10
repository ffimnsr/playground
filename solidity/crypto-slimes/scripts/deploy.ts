import {
    Contract,
    ContractFactory,
} from "ethers";
import { ethers } from "hardhat";

const main = async(): Promise<any> =>  {
    const [deployer] = await ethers.getSigners();

    console.log(`Deploying contracts with the account: ${deployer.address}`);
    console.log(`Account balance: ${(await deployer.getBalance()).toString()}`);

    const cf: ContractFactory = await ethers.getContractFactory("CryptoSlimes");
    const c: Contract = await cf.deploy();

    await c.deployed();
    console.log(`CryptoSlimes deployed to: ${c.address}`);
};

main()
    .then(() => process.exit(0))
    .catch(err => {
        console.error(err);
        process.exit(1);
    });