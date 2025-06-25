import { airdropFactory, appendTransactionMessageInstructions, createSolanaRpc, createSolanaRpcSubscriptions, createTransactionMessage, generateKeyPairSigner, getSignatureFromTransaction, lamports, pipe, sendAndConfirmTransactionFactory, setTransactionMessageFeePayer, setTransactionMessageFeePayerSigner, setTransactionMessageLifetimeUsingBlockhash, signTransactionMessageWithSigners } from "@solana/kit";
import { findAssociatedTokenPda, getCreateAssociatedTokenInstructionAsync, getInitializeMintInstruction, getInitializeNonTransferableMintInstruction, getMintSize, getMintToCheckedInstruction, TOKEN_2022_PROGRAM_ADDRESS } from "@solana-program/token-2022";
import { getCreateAccountInstruction } from "@solana-program/system";

const DECIMALS = 9;

const rpc = createSolanaRpc("http://127.0.0.1:8899");
const rpcSubscriptions = createSolanaRpcSubscriptions("ws://localhost:8900");

const payer = await generateKeyPairSigner();
const { value: latestBlockhash } = await rpc.getLatestBlockhash().send();

console.log("Payer public key:", payer.address);
console.log("Airdropping SOL to the payer...");

await airdropFactory({ rpc, rpcSubscriptions })({
    recipientAddress: payer.address,
    lamports: lamports(1_000_000_000n), // 1 SOL
    commitment: "confirmed",
});

console.log("Creating a mint account...");
const mint = await generateKeyPairSigner();
const space = BigInt(getMintSize());
const rent = await rpc.getMinimumBalanceForRentExemption(space).send();

console.log("Mint public key:", mint.address);

const createAccountIx = getCreateAccountInstruction({
    payer: payer,
    newAccount: mint,
    lamports: rent,
    space,
    programAddress: TOKEN_2022_PROGRAM_ADDRESS,
});

const initializeMintIx = getInitializeMintInstruction({
    mint: mint.address,
    decimals: DECIMALS,
    mintAuthority: payer.address,
});

const [ata] = await findAssociatedTokenPda({
    mint: mint.address,
    owner: payer.address,
    tokenProgram: TOKEN_2022_PROGRAM_ADDRESS,
});

const createAtaIx = await getCreateAssociatedTokenInstructionAsync({
    payer: payer,
    mint: mint.address,
    owner: payer.address,
});

const ixs = [
    createAccountIx,
    initializeMintIx,
    createAtaIx,
];

const txMessage = pipe(
    createTransactionMessage({ version: 0 }),
    (tx) => setTransactionMessageFeePayerSigner(payer, tx),
    (tx) => setTransactionMessageLifetimeUsingBlockhash(latestBlockhash, tx),
    (tx) => appendTransactionMessageInstructions(ixs, tx),
);

const signedTx = await signTransactionMessageWithSigners(
    txMessage,
);

await sendAndConfirmTransactionFactory({ rpc, rpcSubscriptions })(
    signedTx,
    { commitment: "finalized" },
);

const mintToTx = await getMintToCheckedInstruction({
    mint: mint.address,
    token: ata,
    mintAuthority: payer.address,
    amount: 1n * BigInt(10 ** DECIMALS),
    decimals: DECIMALS,
});

const mintToTxMessage = pipe(
    createTransactionMessage({ version: 0 }),
    (tx) => setTransactionMessageFeePayerSigner(payer, tx),
    (tx) => setTransactionMessageLifetimeUsingBlockhash(latestBlockhash, tx),
    (tx) => appendTransactionMessageInstructions([mintToTx], tx),
);
const signedMintToTx = await signTransactionMessageWithSigners(
    mintToTxMessage,
);

await sendAndConfirmTransactionFactory({ rpc, rpcSubscriptions })(
    signedMintToTx,
    { commitment: "finalized" },
);

const txSignature = getSignatureFromTransaction(signedMintToTx);
console.log("Transaction signature: ", txSignature);
