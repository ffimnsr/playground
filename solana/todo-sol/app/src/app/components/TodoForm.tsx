"use client";

import { useForm } from "react-hook-form";
import { Box, Button, FormControl, FormErrorMessage, HStack, Input, StackProps } from "@chakra-ui/react";
import { useTodo } from "../hooks";
import { resolve } from "path";

type FormValues = {
  content: string;
};

function TodoForm() {
  const { initialized, initializeUser, transactionPending, addTodo } = useTodo();
  const stackProps: StackProps = {
    w: "100%",
    maxW: "md",
    alignItems: "stretch",
  };

  const { handleSubmit, register, formState: { errors, isSubmitting } } = useForm<FormValues>();
  const onSubmit = handleSubmit((values: FormValues) => {
    addTodo(values.content);
  });

  return (
    <Box w="md">
      {initialized ?
        <form onClick={onSubmit}>
          <HStack {...stackProps}>
            <FormControl isInvalid={Boolean(errors?.content)}>
              <Input
                variant="filled"
                id="content"
                placeholder="Enter a new todo"
                {...register("content", {
                  required: true,
                  minLength: { value: 4, message: "Todo must be at least 3 characters long"}
                })}
              />
              <FormErrorMessage>
                {errors?.content && errors.content.message}
              </FormErrorMessage>
            </FormControl>
            <Button
              type="submit"
              colorScheme="green"
              isLoading={isSubmitting}
              px="8">Add Todo</Button>
          </HStack>
        </form>
        : <Button w="100%" colorScheme="green" onClick={() => initializeUser()} disabled={transactionPending}>Initialize</Button>}
    </Box>
  );
}

export default TodoForm;
