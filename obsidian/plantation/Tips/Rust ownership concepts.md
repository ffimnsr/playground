#### What is ownership?
Ownership is a discipline for ensuring the **safety** of Rust programs. To understand ownership, we first need to understand what makes a Rust program safe (or unsafe).
#### Variables live in the stack

![[Pasted image 20240909222126.png]]

Variables live in **frames**. A frame is a mapping from variables to values within a single scope, such as a function. For example:

- The frame for `main` at location L1 holds `n = 5`.
- The frame for `plus_one` at L2 holds `x = 5`.
- The frame for `main` at location L3 holds `n = 5; y = 6`.

Frames are organized into a **stack** of currently-called-functions. For example, at L2 the frame for `main` sits above the frame for the called function `plus_one`. After a function returns, Rust deallocates the function’s frame. (Deallocation is also called **freeing** or **dropping**, and we use those terms interchangeably.) This sequence of frames is called a stack because the most recent frame added is always the next frame freed.

When an expression reads a variable, the variable’s value is copied from its slot in the stack frame. For example, if we run this program:

![[Pasted image 20240909222129.png]]

The value of `a` is copied into `b`, and `a` is left unchanged, even after changing `b`.
#### Boxes live in the heap
However, copying data can take up a lot of memory. For example, here’s a slightly different program. This program copies an array with 1 million elements:

![[Pasted image 20240909222234.png]]

Observe that copying `a` into `b` causes the `main` frame to contain 2 million elements.

To transfer access to data without copying it, Rust uses **pointers**. A pointer is a value that describes a location in memory. The value that a pointer points-to is called its **pointee.** One common way to make a pointer is to allocate memory in the **heap**. The heap is a separate region of memory where data can live indefinitely. Heap data is not tied to a specific stack frame. Rust provides a construct called [`Box`](https://doc.rust-lang.org/std/boxed/index.html) for putting data on the heap. For example, we can wrap the million-element array in `Box::new` like this:

![[Pasted image 20240909222344.png]]

Observe that now, there is only ever a single array at a time. At L1, the value of `a` is a pointer (represented by dot with an arrow) to the array inside the heap. The statement `let b = a` copies the pointer from `a` into `b`, but the pointed-to data is not copied. Note that `a` is now grayed out because it has been _moved_ — we will see what that means in a moment.
#### Rust does not permit manual memory management
Memory management is the process of allocating memory and deallocating memory. In other words, it’s the process of finding unused memory and later returning that memory when it is no longer used. Stack frames are automatically managed by Rust. *When a function is called, Rust allocates a stack frame for the called function. When the call ends, Rust deallocates the stack frame.*

#### Box's owner manages deallocation
If a variable is bound to a box, when Rust deallocates the variable’s frame, then Rust deallocates the box’s heap memory.

For example, let’s trace through a program that allocates and frees a box:

![[Pasted image 20240909222803.png]]

At L1, before calling `make_and_drop`, the state of memory is just the stack frame for `main`. Then at L2, while calling `make_and_drop`, `a_box` points to `5` on the heap. Once `make_and_drop` is finished, Rust deallocates its stack frame. `make_and_drop` contains the variable `a_box`, so Rust also deallocates the heap data in `a_box`. Therefore the heap is empty at L3.

#### Collections uses boxes
Boxes are used by Rust data structures[1](https://rust-book.cs.brown.edu/ch04-01-what-is-ownership.html#boxed-data-structures) like [`Vec`](https://doc.rust-lang.org/std/vec/struct.Vec.html), [`String`](https://doc.rust-lang.org/std/string/struct.String.html), and [`HashMap`](https://doc.rust-lang.org/std/collections/struct.HashMap.html) to hold a variable number of elements. For example, here’s a program that creates, moves, and mutates a string:

![[Pasted image 20240909223029.png]]

This program is more involved, so make sure you follow each step:

1. At L1, the string “Ferris” has been allocated on the heap. It is owned by `first`.
2. At L2, the function `add_suffix(first)` has been called. This moves ownership of the string from `first` to `name`. The string data is not copied, but the pointer to the data is copied.
3. At L3, the function `name.push_str(" Jr.")` resizes the string’s heap allocation. This does three things. First, it creates a new larger allocation. Second, it writes “Ferris Jr.” into the new allocation. Third, it frees the original heap memory. `first` now points to deallocated memory.
4. At L4, the frame for `add_suffix` is gone. This function returned `name`, transferring ownership of the string to `full`.
#### Cloning avoids moves
One way to avoid moving data is to _clone_ it using the `.clone()` method. For example, we can fix the safety issue in the previous program with a clone:

![[Pasted image 20240909223422.png]]

Observe that at L1, `first_clone` did not “shallow” copy the pointer in `first`, but instead “deep” copied the string data into a new heap allocation. Therefore at L2, while `first_clone` has been moved and invalidated by `add_suffix`, the original `first` variable is unchanged. It is safe to continue using `first`.
#### Summary
Ownership is primarily a discipline of heap management:[2](https://rust-book.cs.brown.edu/ch04-01-what-is-ownership.html#pointer-management)

- All heap data must be owned by exactly one variable.
- Rust deallocates heap data once its owner goes out of scope.
- Ownership can be transferred by moves, which happen on assignments and function calls.
- Heap data can only be accessed through its current owner, not a previous owner.