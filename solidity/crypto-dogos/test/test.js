const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CryptoDogos", function () {
  it("Should return the right name and symbol", async function () {
    const CryptoDogos = await ethers.getContractFactory("CryptoDogos");
    const cryptoDogos = await CryptoDogos.deploy("CryptoDogos", "CDO");
    await cryptoDogos.deployed();

    expect(await cryptoDogos.name()).to.equal("CryptoDogos");
    expect(await cryptoDogos.symbol()).to.equal("CDO");
  });
});
