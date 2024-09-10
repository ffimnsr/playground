import {
    Contract,
    ContractFactory,
} from "ethers";
import { ethers } from "hardhat";

const main = async(): Promise<any> =>  {
    const [deployer] = await ethers.getSigners();

    console.log(`Deploying contracts with the account: ${deployer.address}`);
    console.log(`Account balance: ${(await deployer.getBalance()).toString()}`);

    const ShibaInu: ContractFactory = await ethers.getContractFactory("ShibaInu");
    const shibaInu: Contract = await ShibaInu.deploy();

    await shibaInu.deployed();
    console.log(`ShibaInu deployed to: ${shibaInu.address}`);
};

main()
    .then(() => process.exit(0))
    .catch(err => {
        console.error(err);
        process.exit(1);
    });