import {
    Contract,
    ContractFactory,
} from "ethers";
import { ethers, network } from "hardhat";
import fs from "fs/promises";

const CONTRACT_NAME = "AFO";

interface DeploymentInfo {
    network: string;
    contract: {
        name: string;
        address: string;
        signerAddress: string;
        abi: string | string[];
    };
}

async function deploy(): Promise<void> {
    const [deployer] = await ethers.getSigners();

    console.log(`Deploying contracts to network ${network.name} with the account ${deployer.address}`);

    const cf: ContractFactory = await ethers.getContractFactory(CONTRACT_NAME);
    const c: Contract = await cf.deploy();
    
    await c.deployed();
    console.log(`Contracts deployed to ${c.address} (network: ${network.name})`);

    const info: DeploymentInfo = {
        network: network.name,
        contract: {
            name: CONTRACT_NAME,
            address: c.address,
            signerAddress: await c.signer.getAddress(),
            abi: c.interface.format(),
        },
    };

    await saveDeploymentInfo(info);
}

async function saveDeploymentInfo(info: DeploymentInfo) {
    const content = JSON.stringify(info, null, 2);
    await fs.writeFile("deployment.json", content, { encoding: "utf-8" });
}

deploy()
    .then(() => process.exit(0))
    .catch(err => {
        console.error(err);
        process.exit(1);
    });
