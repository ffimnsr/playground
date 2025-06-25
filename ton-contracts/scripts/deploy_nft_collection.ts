import {
  beginCell,
  contractAddress,
  toNano,
  Cell,
  type Address,
} from "@ton/core"
import type { NetworkProvider } from "@ton/blueprint"
import { NftCollection } from "../wrappers/nft_collection"

export async function run(provider: NetworkProvider) {
  const OFFCHAIN_CONTENT_PREFIX = 0x01
  const string_first =
    "https://io.ppon.im/data/metadata/" // Change to the content URL you prepared
  const new_content = beginCell()
    .storeInt(OFFCHAIN_CONTENT_PREFIX, 8)
    .storeStringRefTail(string_first)
    .endCell()

  const owner = provider.sender().address as Address
  const collection = provider.open(
    await NftCollection.fromInit(owner, new_content, {
      $$type: "RoyaltyParams",
      numerator: 350n, // 350n = 35%
      denominator: 1000n,
      destination: owner,
    }),
  )

  await collection.send(
    provider.sender(),
    {
      value: toNano("0.01"),
    },
    {
      $$type: "Deploy",
      queryId: 0n,
    }
  )

  await provider.waitForDeploy(collection.address)
  console.log(`Deployed NFT Collection at ${collection.address}`)
}
