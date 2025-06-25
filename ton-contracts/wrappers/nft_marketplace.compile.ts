import type { CompilerConfig } from "@ton/blueprint"

export const compile: CompilerConfig = {
  lang: "tact",
  target: "contracts/nft_marketplace/nft_marketplace.tact",
  options: {
    external: true,
  },
}
