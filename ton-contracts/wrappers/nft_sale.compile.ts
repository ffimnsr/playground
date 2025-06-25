import type { CompilerConfig } from "@ton/blueprint"

export const compile: CompilerConfig = {
  lang: "tact",
  target: "contracts/nft_sale/nft_sale.tact",
  options: {
    external: true,
  },
}
