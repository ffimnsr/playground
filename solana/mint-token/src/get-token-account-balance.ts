import { address, createSolanaRpc } from "@solana/kit";

const rpc = createSolanaRpc("http://127.0.0.1:8899");

const tokenAccountAddress = address(
	"Bziu7M9PShsYQBTNzzjpryMz71heEizDmdiTyTFoEnSa"
);

const balance = await rpc.getTokenAccountBalance(tokenAccountAddress).send();
console.log(balance);