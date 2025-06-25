import { Address, createSolanaRpc } from "@solana/kit";
import { fetchMint } from "@solana-program/token-2022";

const rpc = createSolanaRpc("http://127.0.0.1:8899");
const address = "AJMDT8hShJmSHKswjnj5pGHgHGivELY4N9ZfczB7tmvc" as Address;

const mint = await fetchMint(rpc, address);
console.log(mint);