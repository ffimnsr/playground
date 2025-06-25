import {
	fetchToken,
	findAssociatedTokenPda,
	TOKEN_2022_PROGRAM_ADDRESS,
} from "@solana-program/token-2022";
import { type Address, createSolanaRpc } from "@solana/kit";

const rpc = createSolanaRpc("http://127.0.0.1:8899");

const mintAddress = "AJMDT8hShJmSHKswjnj5pGHgHGivELY4N9ZfczB7tmvc" as Address;
const authority = "BNK2pom1ovV4SmhDodNW1pUo8eKmY5mJhuQHc9VXCrdB" as Address;

const [associatedTokenAddress] = await findAssociatedTokenPda({
	mint: mintAddress,
	owner: authority,
	tokenProgram: TOKEN_2022_PROGRAM_ADDRESS,
});

const ataDetails = await fetchToken(rpc, associatedTokenAddress);
console.log(ataDetails);