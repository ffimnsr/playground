"use client";

import { HStack, IconButton, Spacer, VStack, Text, StackDivider, border, StackProps, IconButtonProps } from "@chakra-ui/react";
import { FaCheck, FaMinus, FaPlus, FaTrash } from "react-icons/fa";
import { Todo } from "../hooks";
import { ProgramAccount } from "@coral-xyz/anchor";
import { PublicKey } from '@solana/web3.js';

type Props = {
  todos: ProgramAccount<Todo>[];
  markTodo: (todoPda: PublicKey, todoIdx: number) => Promise<void>;
  unmarkTodo: (todoPda: PublicKey, todoIdx: number) => Promise<void>;
  removeTodo: (todoPda: PublicKey, todoIdx: number) => Promise<void>;
};

function TodoList({ todos, markTodo, unmarkTodo, removeTodo }: Props) {
  const itemListStackProps: StackProps = {
    p: "2",
    w: "100%",
    maxW: "md",
    borderRadius: "lg",
    borderWidth: "1px",
    borderColor: "gray.200",
    alignItems: "stretch",
    divider: <StackDivider />,
  };

  const removeItemButtonProps: IconButtonProps = {
    icon: <FaTrash />,
    "aria-label": "Delete Todo",
  };

  const unmarkedItemButtonProps: IconButtonProps = {
    icon: <FaPlus />,
    "aria-label": "Mark Todo",
  };

  const markedItemButtonProps: IconButtonProps = {
    icon: <FaCheck />,
    colorScheme: "green",
    "aria-label": "Marked Todo",
  };

  return (
    <VStack {...itemListStackProps}>
      {todos.map(todo => (
        <HStack key={todo.account.idx} p="2">
          {todo.account.marked ?
            <IconButton onClick={() => unmarkTodo(todo.publicKey, todo.account.idx)} {...markedItemButtonProps} />
            : <IconButton onClick={() => markTodo(todo.publicKey, todo.account.idx)} {...unmarkedItemButtonProps} />}
          <Text marginLeft={4}>{todo.account.content}</Text>
          <Spacer />
          <IconButton {...removeItemButtonProps} />
        </HStack>
      ))}
    </VStack>
  );
}

export default TodoList;
