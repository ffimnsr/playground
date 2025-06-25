import { toNano, beginCell, Address, Cell } from "@ton/core"
import { Blockchain, SandboxContract, TreasuryContract } from "@ton/sandbox"
import "@ton/test-utils"

import { NftCollection } from "../wrappers/nft_collection"
import { NftItem } from "../wrappers/nft_item"

describe("contract", () => {
  const OFFCHAIN_CONTENT_PREFIX = 0x01
  const string_first =
    "https://s.getgems.io/nft-staging/c/628f6ab8077060a7a8d52d63/"
  const newContent = beginCell()
    .storeInt(OFFCHAIN_CONTENT_PREFIX, 8)
    .storeStringRefTail(string_first)
    .endCell()

  let blockchain: Blockchain
  let deployer: SandboxContract<TreasuryContract>
  let collection: SandboxContract<NftCollection>
  let nft: SandboxContract<NftItem>
  let user: SandboxContract<TreasuryContract>

  beforeAll(async () => {
    blockchain = await Blockchain.create()
    deployer = await blockchain.treasury("deployer")
    user = await blockchain.treasury("user")

    collection = blockchain.openContract(
      await NftCollection.fromInit(
        deployer.address,
        newContent,
        {
          $$type: "RoyaltyParams",
          numerator: 350n, // 350n = 35%
          denominator: 1000n,
          destination: deployer.address,
        },
        2n,
      ),
    )

    const deploy_result = await collection.send(
      deployer.getSender(),
      { value: toNano(1) },
      {
        $$type: "Deploy",
        queryId: 0n,
      },
    )

    expect(deploy_result.transactions).toHaveTransaction({
      from: deployer.address,
      to: collection.address,
      deploy: true,
      success: true,
    })
  })

  it("should show correct collection data", async () => {
    const result = await collection.getGetCollectionData()
    expect(result.owner_address.toString()).toStrictEqual(
      deployer.address.toString(),
    )
    expect(result.next_item_index).toStrictEqual(0n)
    const b = beginCell()
      .storeInt(OFFCHAIN_CONTENT_PREFIX, 8)
      .storeStringTail(string_first)
      .storeStringTail("meta.json")
      .endCell()
      .asSlice()
      .toString()
    expect(result.collection_content.asSlice().toString()).toStrictEqual(b)
  })

  it("should show correct collection developer", async () => {
    const result = await collection.getDeveloper()
    const b = beginCell().storeStringTail("po.ppon.im").endCell()
    expect(result.asSlice().toString()).toStrictEqual(b.asSlice().toString())
  })

  it("should mint initial", async () => {
    const result = await collection.send(
      deployer.getSender(),
      { value: toNano(1) },
      {
        $$type: "Mint",
        query_id: 0n,
      },
    )

    const nftAddress = new Address(
      0,
      Buffer.from(result.transactions[2].address.toString(16), "hex"),
    )

    expect(result.transactions).toHaveTransaction({
      from: collection.address,
      to: nftAddress,
      deploy: true,
      success: true,
    })

    console.log(
      "Next Index: " +
        (await collection.getGetCollectionData()).next_item_index,
    )
    console.log("Collection Address: " + collection.address)
  })

  it("should mint correctly", async () => {
    const result = await collection.send(
      deployer.getSender(),
      {
        value: toNano(1),
      },
      {
        $$type: "Mint",
        query_id: 0n,
      },
    )

    const nftAddress = new Address(
      0,
      Buffer.from(result.transactions[2].address.toString(16), "hex"),
    )

    console.log(
      "Next Index: " +
        (await collection.getGetCollectionData()).next_item_index,
    )

    expect(result.transactions).toHaveTransaction({
      from: collection.address,
      to: nftAddress,
      deploy: true,
      success: true,
    })

    nft = blockchain.openContract(NftItem.fromAddress(nftAddress))

    const data = await nft.getGetNftData()
    expect(data.owner_address.toString()).toStrictEqual(
      deployer.address.toString(),
    )
    expect(data.collection_address.toString()).toStrictEqual(
      collection.address.toString(),
    )
    expect(data.index).toStrictEqual(1n)
  })

  it("should show correct editor data", async () => {
    const result = await nft.getGetEditor()
    expect(result.toString()).toStrictEqual(deployer.address.toString())
  })

  it("should show correct collection address", async () => {
    const result = await nft.getGetCollectionAddress()
    expect(result.toString()).toStrictEqual(collection.address.toString())
  })

  it("should fail to mint as hits the total supply", async () => {
    const result = await collection.send(
      deployer.getSender(),
      {
        value: toNano(1),
      },
      {
        $$type: "Mint",
        query_id: 0n,
      },
    )

    expect(result.transactions).toHaveTransaction({
      from: deployer.address,
      to: collection.address,
      success: false,
    })
  })

  it("should transfer", async () => {
    const result = await nft.send(
      deployer.getSender(),
      {
        value: toNano("0.2"),
      },
      {
        $$type: "Transfer",
        query_id: 0n,
        new_owner: user.address,
        response_destination: user.address,
        custom_payload: null,
        forward_amount: 0n,
        forward_payload: Cell.EMPTY.asSlice(),
      },
    )

    expect(result.transactions).toHaveTransaction({
      from: deployer.address,
      to: nft.address,
      success: true,
    })
    expect(result.transactions).toHaveTransaction({
      from: nft.address,
      to: user.address,
      success: true,
    })
    expect((await nft.getGetNftData()).owner_address.toString()).toStrictEqual(
      user.address.toString(),
    )
  })

  it("should transfer editorship", async () => {
    await nft.send(
      deployer.getSender(),
      {
        value: toNano("0.2"),
      },
      {
        $$type: "TransferEditorship",
        query_id: 0n,
        new_editor: user.address,
        response_destination: user.address,
        forward_amount: 0n,
        forward_payload: Cell.EMPTY.asSlice(),
      },
    )
    expect((await nft.getGetNftData()).editor_address.toString()).toStrictEqual(
      user.address.toString(),
    )
  })

  it("should edit content metadata", async () => {
    const newContent = beginCell().storeStringTail("Spite").endCell()
    const result = await nft.send(
      user.getSender(),
      {
        value: toNano("0.2"),
      },
      {
        $$type: "EditContent",
        query_id: 0n,
        new_content: newContent,
      },
    )
    expect(result.transactions).toHaveTransaction({
      from: user.address,
      to: nft.address,
      success: true,
    })
    const content = beginCell()
      .storeStringTail("Spite") // collection data
      .storeStringTail("1") // index
      .storeStringTail(".json")
      .endCell()

    expect(
      (await nft.getGetNftData()).individual_content.hash().toString("hex"),
    ).toStrictEqual(content.hash().toString("hex"))
  })
})
