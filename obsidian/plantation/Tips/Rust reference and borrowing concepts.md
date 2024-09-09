Ownership, boxes, and moves provide a foundation for safely programming with the heap. However, move-only APIs can be inconvenient to use. For example, say you want to read some strings twice:

![[Pasted image 20240909223924.png]]

In this example, calling `greet` moves the data from `m1` and `m2` into the parameters of `greet`. Both strings are dropped at the end of `greet`, and therefore cannot be used within `main`. If we try to read them like in the operation `format!(..)`, then that would be undefined behavior. The Rust compiler therefore rejects this program with the same error we saw last section:

```text
error[E0382]: borrow of moved value: `m1`
 --> test.rs:5:30
 (...rest of the error...)
```

This move behavior is extremely inconvenient. Programs often need to use a string more than once. An alternative `greet` could return ownership of the strings, like this:

![[Pasted image 20240909224005.png]]

However, this style of program is quite verbose. Rust provides a concise style of reading and writing without moves through references.
#### References are non-owning pointers
A **reference** is a kind of pointer. Here’s an example of a reference that rewrites our `greet` program in a more convenient manner:

![[Pasted image 20240909224058.png]]

The expression `&m1` uses the ampersand operator to create a reference to (or “borrow”) `m1`. The type of the `greet` parameter `g1` is changed to `&String`, meaning “a reference to a `String`”.

Observe at L2 that there are two steps from `g1` to the string “Hello”. `g1` is a reference that points to `m1` on the stack, and `m1` is a String containing a box that points to “Hello” on the heap.

While `m1` owns the heap data “Hello”, `g1` does _not_ own either `m1` or “Hello”. Therefore after `greet` ends and the program reaches L3, no heap data has been deallocated. Only the stack frame for `greet` disappears. This fact is consistent with our _Box Deallocation Principle_. Because `g1` did not own “Hello”, Rust did not deallocate “Hello” on behalf of `g1`.

References are **non-owning pointers**, because they do not own the data they point to.
#### Dereferencing a pointer accesses its data
The previous examples using boxes and strings have not shown how Rust “follows” a pointer to its data. For example, the `println!` macro has mysteriously worked for both owned strings of type `String`, and for string references of type `&String`. The underlying mechanism is the **dereference** operator, written with an asterisk (`*`). For example, here’s a program that uses dereferences in a few different ways:

![[Pasted image 20240909224501.png]]

Observe the difference between `r1` pointing to `x` on the stack, and `r2` pointing to the heap value `2`.

You probably won’t see the dereference operator very often when you read Rust code. Rust implicitly inserts dereferences and references in certain cases, such as calling a method with the dot operator. For example, this program shows two equivalent ways of calling the [`i32::abs`](https://doc.rust-lang.org/std/primitive.i32.html#method.abs) (absolute value) and [`str::len`](https://doc.rust-lang.org/std/primitive.str.html#method.len) (string length) functions:

```rust
let x: Box<i32> = Box::new(-1);
let x_abs1 = i32::abs(*x); // explicit dereference
let x_abs2 = x.abs();      // implicit dereference
assert_eq!(x_abs1, x_abs2);

let r: &Box<i32> = &x;
let r_abs1 = i32::abs(**r); // explicit dereference (twice)
let r_abs2 = r.abs();       // implicit dereference (twice)
assert_eq!(r_abs1, r_abs2);

let s = String::from("Hello");
let s_len1 = str::len(&s); // explicit reference
let s_len2 = s.len();      // implicit reference
assert_eq!(s_len1, s_len2);
```

This example shows implicit conversions in three ways:

1. The `i32::abs` function expects an input of type `i32`. To call `abs` with a `Box<i32>`, you can explicitly dereference the box like `i32::abs(*x)`. You can also implicitly dereference the box using method-call syntax like `x.abs()`. The dot syntax is syntactic sugar for the function-call syntax.
    
2. This implicit conversion works for multiple layers of pointers. For example, calling `abs` on a reference to a box `r: &Box<i32>` will insert two dereferences.
    
3. This conversion also works the opposite direction. The function `str::len` expects a reference `&str`. If you call `len` on an owned `String`, then Rust will insert a single borrowing operator. (In fact, there is a further conversion from `String` to `str`!)
#### Rust avoids simultaneous aliasing and mutation
Pointers are a powerful and dangerous feature because they enable **aliasing**. Aliasing is accessing the same data through different variables. On its own, aliasing is harmless. But combined with **mutation**, we have a recipe for disaster. One variable can “pull the rug out” from another variable in many ways, for example:

- By deallocating the aliased data, leaving the other variable to point to deallocated memory.
- By mutating the aliased data, invalidating runtime properties expected by the other variable.
- By _concurrently_ mutating the aliased data, causing a data race with nondeterministic behavior for the other variable.

As a running example, we are going to look at programs using the vector data structure, [`Vec`](https://doc.rust-lang.org/std/vec/struct.Vec.html). Unlike arrays which have a fixed length, vectors have a variable length by storing their elements in the heap. For example, [`Vec::push`](https://doc.rust-lang.org/std/vec/struct.Vec.html#method.push) adds an element to the end of a vector, like this:

![[Pasted image 20240909224801.png]]

The macro `vec!` creates a vector with the elements between the brackets. The vector `v` has type `Vec<i32>`. The syntax `<i32>` means the elements of the vector have type `i32`.

One important implementation detail is that `v` allocates a heap array of a certain _capacity_. We can peek into `Vec`’s internals and see this detail for ourselves:

![[Pasted image 20240909224909.png]]

Notice that the vector has a length (`len`) of 3 and a capacity (`cap`) of 3. The vector is at capacity. So when we do a `push`, the vector has to create a new allocation with larger capacity, copy all the elements over, and deallocate the original heap array. In the diagram above, the array `1 2 3 4` is in a (potentially) different memory location than the original array `1 2 3`.

To tie this back to memory safety, let’s bring references into the mix. Say we created a reference to a vector’s heap data. Then that reference can be invalidated by a push, as simulated below:

![[Pasted image 20240909225124.png]]

Initially, `v` points to an array with 3 elements on the heap. Then `num` is created as a reference to the third element, as seen at L1. However, the operation `v.push(4)` resizes `v`. The resize will deallocate the previous array and allocate a new, bigger array. In the process, `num` is left pointing to invalid memory. Therefore at L3, dereferencing `*num` reads invalid memory, causing undefined behavior.

In more abstract terms, the issue is that the vector `v` is both aliased (by the reference `num`) and mutated (by the operation `v.push(4)`). So to avoid these kinds of issues, Rust follows a basic principle:

> **Pointer Safety Principle**: data should never be aliased and mutated at the same time.

Data can be aliased. Data can be mutated. But data cannot be _both_ aliased _and_ mutated. For example, Rust enforces this principle for boxes (owned pointers) by disallowing aliasing. Assigning a box from one variable to another will move ownership, invalidating the previous variable. Owned data can only be accessed through the owner — no aliases.

However, because references are non-owning pointers, they need different rules than boxes to ensure the _Pointer Safety Principle_. By design, references are meant to temporarily create aliases.
#### References change permissions on paths
The core idea behind the borrow checker is that variables have three kinds of **permissions** on their data:

- **Read** (R): data can be copied to another location.
- **Write** (W): data can be mutated in-place.
- **Own** (O): data can be moved or dropped.

These permissions don’t exist at runtime, only within the compiler. They describe how the compiler “thinks” about your program before the program is executed.

By default, a variable has read/own permissions (RO) on its data. If a variable is annotated with `let mut`, then it also has the write permission (W). The key idea is that **references can temporarily remove these permissions.**

To illustrate this idea, let’s look at the permissions on a variation of the program above that is actually safe. The `push` has been moved after the `println!`. The permissions in this program are visualized with a new kind of diagram. The diagram shows the changes in permissions on each line.

![[Pasted image 20240909225444.png]]

Let’s walk through each line:

1. After `let mut v = (...)`, the variable `v` has been initialized (indicated by ). It gains +R+W+O permissions (the plus sign indicates gain).
2. After `let num = &v[2]`, the data in `v` has been **borrowed** by `num` (indicated by ). Three things happen:
    - The borrow removes 
        
        W
        
        O permissions from `v` (the slash indicates loss). `v` cannot be written or owned, but it can still be read.
    - The variable `num` has gained RO permissions. `num` is not writable (the missing W permission is shown as a dash ‒) because it was not marked `let mut`.
    - The **path** `*num` has gained the R permission.
3. After `println!(...)`, then `num` is no longer in use, so `v` is no longer borrowed. Therefore:
    - `v` regains its WO permissions (indicated by ).
    - `num` and `*num` have lost all of their permissions (indicated by ).
4. After `v.push(4)`, then `v` is no longer in use, and it loses all of its permissions.

Next, let’s explore a few nuances of the diagram. First, why do you see both `num` and `*num`? Because it’s different to access data through a reference, versus to manipulate the reference itself. For example, say we declared a reference to a number with `let mut`:

![[Pasted image 20240909225703.png]]

Notice that `x_ref` has the W permission, while `*x_ref` does not. That means we can assign `x_ref` to a different reference (e.g. `x_ref = &y`), but we cannot mutate the pointed data (e.g. `*x_ref += 1`).

More generally, permissions are defined on **paths** and not just variables. A path is anything you can put on the left-hand side of an assignment. Paths include:

- Variables, like `a`.
- Dereferences of paths, like `*a`.
- Array accesses of paths, like `a[0]`.
- Fields of paths, like `a.0` for tuples or `a.field` for structs (discussed next chapter).
- Any combination of the above, like `*((*a)[0].1)`.

Second, why do paths lose permissions when they become unused? Because some permissions are mutually exclusive. If `num = &v[2]`, then `v` cannot be mutated or dropped while `num` is in use. But that doesn’t mean it’s invalid to use `num` for more time. For example, if we add another `print` to the above program, then `num` simply loses its permissions later:

![[Pasted image 20240909230010.png]]
#### Mutable references provide unique and non-owning access to data
The references we have seen so far are read-only **immutable references** (also called **shared references**). Immutable references permit aliasing but disallow mutation. However, it is also useful to temporarily provide mutable access to data without moving it.

The mechanism for this is **mutable references** (also called **unique references**). Here’s a simple example of a mutable reference with the accompanying permissions changes:

![[Pasted image 20240909230342.png]]

A mutable reference is created with the `&mut` operator. The type of `num` is written as `&mut i32`. Compared to immutable references, you can see two important differences in the permissions:

1. When `num` was an immutable reference, `v` still had the R permission. Now that `num` is a mutable reference, `v` has lost _all_ permissions while `num` is in use.
2. When `num` was an immutable reference, the path `*num` only had the R permission. Now that `num` is a mutable reference, `*num` has also gained the W permission.

The first observation is what makes mutable references _safe_. Mutable references allow mutation but prevent aliasing. The borrowed path `v` becomes temporarily unusable, so effectively not an alias.

The second observation is what makes mutable references _useful_. `v[2]` can be mutated through `*num`. For example, `*num += 1` mutates `v[2]`. Note that `*num` has the W permission, but `num` does not. `num` refers to the mutable reference itself, e.g. `num` cannot be reassigned to a _different_ mutable reference.

Mutable references can also be temporarily “downgraded” to read-only references. For example:

![[Pasted image 20240909230611.png]]

In this program, the borrow `&*num` removes the W permission from `*num` but _not_ the R permission, so `println!(..)` can read both `*num` and `*num2`.
#### Permissions are returned at the end of a reference's lifetime
We said above that a reference changes permissions while it is “in use”. The phrase “in use” is describing a reference’s **lifetime**, or the range of code spanning from its birth (where the reference is created) to its death (the last time(s) the reference is used).

For example, in this program, the lifetime of `y` starts with `let y = &x`, and ends with `let z = *y`:

![[Pasted image 20240909230737.png]]

The W permission on `x` is returned to `x` after the lifetime of `y` has ended, like we have seen before.

In the previous examples, a lifetime has been a contiguous region of code. However, once we introduce control flow, this is not necessarily the case. For example, here is a function that capitalizes the first character in a vector of ASCII characters:

![[Pasted image 20240909230920.png]]

The variable `c` has a different lifetime in each branch of the if-statement. In the then-block, `c` is used in the expression `c.to_ascii_uppercase()`. Therefore `*v` does not regain the W permission until after that line.

However, in the else-block, `c` is not used. `*v` immediately regains the W permission on entry to the else-block.
#### Data must outlive all of its references
Rust enforces this property in two ways. The first way deals with references that are created and dropped within the scope of a single function. For example, say we tried to drop a string while holding a reference to it:

![[Pasted image 20240909231105.png]]

To catch these kinds of errors, Rust uses the permissions we’ve already discussed. The borrow `&s` removes the O permission from `s`. However, `drop` expects the O permission, leading to a permission mismatch.

The key idea is that in this example, Rust knows how long `s_ref` lives. But Rust needs a different enforcement mechanism when it doesn’t know how long a reference lives. Specifically, when references are either input to a function, or output from a function. For example, here is a safe function that returns a reference to the first element in a vector:

![[Pasted image 20240909231209.png]]

This snippet introduces a new kind of permission, the flow permission F. The F permission is expected whenever an expression uses an input reference (like `&strings[0]`), or returns an output reference (like `return s_ref`).

Unlike the RWO permissions, F does not change throughout the body of a function. A reference has the F permission if it’s allowed to be used (that is, to _flow_) in a particular expression. For example, let’s say we change `first` to a new function `first_or` that includes a `default` parameter:

![[Pasted image 20240909231315.png]]

This function no longer compiles, because the expressions `&strings[0]` and `default` lack the necessary F permission to be returned. But why? Rust gives the following error:

```text
error[E0106]: missing lifetime specifier
 --> test.rs:1:57
  |
1 | fn first_or(strings: &Vec<String>, default: &String) -> &String {
  |                      ------------           -------     ^ expected named lifetime parameter
  |
  = help: this function's return type contains a borrowed value, but the signature does not say whether it is borrowed from `strings` or `default`
```

The message “missing lifetime specifier” is a bit mysterious, but the help message provides some useful context. If Rust _just_ looks at the function signature, it doesn’t know whether the output `&String` is a reference to either `strings` or `default`. To understand why that matters, let’s say we used `first_or` like this:

```rust
fn main() {
    let strings = vec![];
    let default = String::from("default");
    let s = first_or(&strings, &default);
    drop(default);
    println!("{}", s);
}
```

This program is unsafe if `first_or` allows `default` to _flow_ into the return value. Like the previous example, `drop` could invalidate `s`. Rust would only allow this program to compile if it was _certain_ that `default` cannot flow into the return value.

To specify whether `default` can be returned, Rust provides a mechanism called _lifetime parameters_. We will explain that feature later in Chapter 10.3, [“Validating References with Lifetimes”](https://rust-book.cs.brown.edu/ch10-03-lifetime-syntax.html). For now, it’s enough to know that: (1) input/output references are treated differently than references within a function body, and (2) Rust uses a different mechanism, the F permission, to check the safety of those references.

To see the F permission in another context, say you tried to return a reference to a variable on the stack like this:

![[Pasted image 20240909231458.png]]

This program is unsafe because the reference `&s` will be invalidated when `return_a_string` returns. And Rust will reject this program with a similar `missing lifetime specifier` error. Now you can understand that error means that `s_ref` is missing the appropriate flow permissions.
#### Summary
References provide the ability to read and write data without consuming ownership of it. References are created with borrows (`&` and `&mut`) and used with dereferences (`*`), often implicitly.

However, references can be easily misused. Rust’s borrow checker enforces a system of permissions that ensures references are used safely:

- All variables can read, own, and (optionally) write their data.
- Creating a reference will transfer permissions from the borrowed path to the reference.
- Permissions are returned once the reference’s lifetime has ended.
- Data must outlive all references that point to it.