import { Contract } from "ethers";
import { ethers } from "hardhat";
import fs from "fs/promises";
import { CID } from "multiformats/cid";

const OWNER = "";
const IPFS_HASH_V0 = "";

interface DeploymentInfo {
    network: string;
    contract: {
        name: string;
        address: string;
        signerAddress: string;
        abi: string | string[];
    };
}

async function mintToken(contract: Contract, ownerAddress: string, metadataURI: string) {
    const initialMetadataUri = ensureIpfsUriPrefix(metadataURI);
    const uri = stripIpfsUriPrefix(initialMetadataUri);
    const tx = await contract.mintToken(ownerAddress, uri);
    const receipt = await tx.wait();
    for (const event of receipt.events) {
        if (event.event !== "Transfer") {
            console.log("ignoring unknown event type ", event.event);
            continue;
        }
        return event.args.tokenId.toString();
    }
    throw new Error("unable to get token id");
}

function stripIpfsUriPrefix(cidOrURI: string) {
    if (cidOrURI.startsWith("ipfs://")) {
        return cidOrURI.slice("ipfs://".length);
    }
    return cidOrURI;
}

function ensureIpfsUriPrefix(cidOrURI: string) {
    let uri = cidOrURI.toString();
    if (!uri.startsWith("ipfs://")) {
        uri = "ipfs://" + cidOrURI;
    }
    // Avoid the Nyan Cat bug (https://github.com/ipfs/go-ipfs/pull/7930)
    if (uri.startsWith("ipfs://ipfs/")) {
      uri = uri.replace("ipfs://ipfs/", "ipfs://");
    }
    return uri;
}

async function loadDeploymentInfo(): Promise<DeploymentInfo> {
    const content = await fs.readFile("deployment.json", { encoding: "utf-8" });
    const info: DeploymentInfo = JSON.parse(content);

    return info;
}

const main = async(): Promise<any> =>  {
    const { abi, address } = (await loadDeploymentInfo()).contract;
    const contract = await ethers.getContractAt(abi, address);

    const hash = CID.parse(IPFS_HASH_V0).toV1().toString();
    const tokenId = await mintToken(contract, OWNER, `ipfs://${hash}/metadata.json`);
    console.log(`Successfully minted token id ${tokenId}`);
};

main()
    .then(() => process.exit(0))
    .catch(err => {
        console.error(err);
        process.exit(1);
    });