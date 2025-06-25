import { beginCell, contractAddress, toNano, Cell, Address } from "@ton/core"
import { type NetworkProvider, sleep } from "@ton/blueprint"
import { NftCollection } from "../wrappers/nft_collection"

export async function run(provider: NetworkProvider) {
  const collection_address = Address.parse("EQDNc0iq3S6-Mac8zW3NDCJVIa8v9Jd22NwsgUSeBNwwoWN2")

  const collection = provider.open(
    NftCollection.fromAddress(collection_address),
  )

  await collection.send(
    provider.sender(),
    {
      value: toNano(1),
    },
    "Mint",
  )

  // console.log(`NFT ID[${nft_index}]: ${address_by_index}`)
}
