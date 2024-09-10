import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { HelloSol } from "../target/types/hello_sol";
import { expect } from "chai";

describe("hello-sol", () => {
  // Configure the client to use the local cluster.
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.HelloSol as Program<HelloSol>;
  const counter = anchor.web3.Keypair.generate();

  it("Is initialized!", async () => {
    // Add your test here.
    const tx = await program.methods
      .initialize()
      .accounts({ counter: counter.publicKey })
      .signers([counter])
      .rpc();
    console.log("Your transaction signature", tx);

    const account = await program.account.counter.fetch(counter.publicKey);
    expect(account.count.toNumber()).to.eq(0);
  });

  it("Increments counter", async () => {
    const tx = await program.methods
      .increment()
      .accounts({ counter: counter.publicKey, user: provider.wallet.publicKey})
      .rpc();
    console.log("Your transaction signature", tx);

    const account = await program.account.counter.fetch(counter.publicKey);
    expect(account.count.toNumber()).to.eq(1);
  });

  it("Decrements counter", async () => {
    const tx = await program.methods
      .decrement()
      .accounts({ counter: counter.publicKey, user: provider.wallet.publicKey})
      .rpc();
    console.log("Your transaction signature", tx);

    const account = await program.account.counter.fetch(counter.publicKey);
    expect(account.count.toNumber()).to.eq(0);
  });
});
