import { beginCell, contractAddress, toNano, Cell, Address } from "@ton/core"
import { type NetworkProvider, sleep } from "@ton/blueprint"
import { NftCollection } from "../wrappers/nft_collection"

export async function run(provider: NetworkProvider) {
  const collection_address = Address.parse("EQC_tXwiun_jSNhLSO2UramdZhIC2xUC7P1WU2sanzmaD7po")

  const collection = provider.open(
    NftCollection.fromAddress(collection_address),
  )

  const nft_index = 0n
  const address_by_index = await collection.getGetNftAddressByIndex(nft_index)

  console.log(`NFT ID[${nft_index}]: ${address_by_index}`)
}
