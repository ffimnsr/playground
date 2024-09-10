"use client";

import { HStack, Heading, Spacer, StackProps, VStack } from "@chakra-ui/react";
import TodoForm from "./components/TodoForm";
import TodoList from "./components/TodoList";
import { WalletMultiButton } from "@solana/wallet-adapter-react-ui";
import { Todo, useIsMounted, useTodo } from "./hooks";
import { useEffect, useState } from "react";
import { ProgramAccount } from "@coral-xyz/anchor";

export default function Home() {
  const mounted = useIsMounted();
  const { todos, markTodo, unmarkTodo, removeTodo } = useTodo();
  const stackProps: StackProps = {
    p: 4,
  };

  return (
    <main>
      <VStack {...stackProps}>
        <HStack w="md">
          <Heading size="xl">My TODO List</Heading>
          <Spacer />
          {mounted && <WalletMultiButton />}
        </HStack>
        <TodoForm />
        <TodoList
          todos={todos}
          markTodo={markTodo}
          unmarkTodo={unmarkTodo}
          removeTodo={removeTodo}
        />
      </VStack>
    </main>
  );
}
