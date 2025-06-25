import type { CompilerConfig } from "@ton/blueprint"

export const compile: CompilerConfig = {
  lang: "tact",
  target: "contracts/nft_marketplace_v2/nft_marketplace_v2.tact",
  options: {
    external: true,
  },
}
