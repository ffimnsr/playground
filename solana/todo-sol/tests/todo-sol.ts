import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { TodoSol } from "../target/types/todo_sol";
import { expect } from "chai";

describe("todo-sol", () => {
  // Configure the client to use the local cluster.
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.TodoSol as Program<TodoSol>;
  const authority = provider.wallet;
  const [todoUserProfilePda] = anchor.web3.PublicKey
    .findProgramAddressSync(
      [
        anchor.utils.bytes.utf8.encode("USER_STATE"),
        authority.publicKey.toBuffer(),
      ],
      program.programId
    );

  const [todoAccountPda] = anchor.web3.PublicKey
    .findProgramAddressSync(
      [
        anchor.utils.bytes.utf8.encode("TODO_STATE"),
        authority.publicKey.toBuffer(),
        Uint8Array.from([0]),
      ],
      program.programId
    );

  it("Is initialized", async () => {
    const tx = await program.methods
      .initialize()
      .rpc();
    console.log("Your transaction signature", tx);

    const userProfile = await program.account.userProfile.fetch(todoUserProfilePda);
    expect(userProfile.todoCount).to.eq(0);
    expect(userProfile.lastTodo).to.eq(0);
  });

  it("Can create a task", async () => {
    const tx = await program.methods
      .addTodo("Buy milk")
      .accounts({ todoAccount: todoAccountPda })
      .rpc();
    console.log("Your transaction signature", tx);

    const todoAccount = await program.account.todoAccount.fetch(todoAccountPda);
    expect(todoAccount.idx).to.eq(0);
    expect(todoAccount.marked).to.false;
    expect(todoAccount.content).to.eq("Buy milk");

    const userProfile = await program.account.userProfile.fetch(todoUserProfilePda);
    expect(userProfile.todoCount).to.eq(1);
    expect(userProfile.lastTodo).to.eq(1);
  });

  it("Can mark a task as done", async () => {
    const tx = await program.methods
      .markTodo(0)
      .accounts({ todoAccount: todoAccountPda })
      .rpc();
    console.log("Your transaction signature", tx);

    const todoAccount = await program.account.todoAccount.fetch(todoAccountPda);
    expect(todoAccount.idx).to.eq(0);
    expect(todoAccount.marked).to.true;
    expect(todoAccount.content).to.eq("Buy milk");
  });

  it("Can unmark a task as not yet done", async () => {
    const tx = await program.methods
      .unmarkTodo(0)
      .accounts({ todoAccount: todoAccountPda })
      .rpc();
    console.log("Your transaction signature", tx);

    const todoAccount = await program.account.todoAccount.fetch(todoAccountPda);
    expect(todoAccount.idx).to.eq(0);
    expect(todoAccount.marked).to.false;
    expect(todoAccount.content).to.eq("Buy milk");
  });

  it("Can remove a task", async () => {
    const tx = await program.methods
      .removeTodo(0)
      .accounts({ todoAccount: todoAccountPda })
      .rpc();
    console.log("Your transaction signature", tx);

    const todoAccount = await program.account.todoAccount.fetch(todoAccountPda);
    expect(todoAccount.idx).to.eq(0);
    expect(todoAccount.content).to.eq("Buy milk");

    const userProfile = await program.account.userProfile.fetch(todoUserProfilePda);
    expect(userProfile.todoCount).to.eq(0);
    expect(userProfile.lastTodo).to.eq(1);
  });
});
