Rust’s closures are anonymous functions you can save in a variable or pass as arguments to other functions. You can create the closure in one place and then call the closure elsewhere to evaluate it in a different context. Unlike functions, closures can capture values from the scope in which they’re defined. We’ll demonstrate how these closure features allow for code reuse and behavior customization.

There are more differences between functions and closures. Closures don’t usually require you to annotate the types of the parameters or the return value like `fn` functions do. Type annotations are required on functions because the types are part of an explicit interface exposed to your users. Defining this interface rigidly is important for ensuring that everyone agrees on what types of values a function uses and returns. Closures, on the other hand, aren’t used in an exposed interface like this: they’re stored in variables and used without naming them and exposing them to users of our library.

Closures are typically short and relevant only within a narrow context rather than in any arbitrary scenario. Within these limited contexts, the compiler can infer the types of the parameters and the return type, similar to how it’s able to infer the types of most variables (there are rare cases where the compiler needs closure type annotations too).

As with variables, we can add type annotations if we want to increase explicitness and clarity at the cost of being more verbose than is strictly necessary.
#### Capturing references or moving ownership
Closures can capture values from their environment in three ways, which directly map to the three ways a function can take a parameter: borrowing immutably, borrowing mutably, and taking ownership. The closure will decide which of these to use based on what the body of the function does with the captured values.

If you want to force the closure to take ownership of the values it uses in the environment even though the body of the closure doesn’t strictly need ownership, you can use the `move` keyword before the parameter list.

This technique is mostly useful when passing a closure to a new thread to move the data so that it’s owned by the new thread.

```rust
use std::thread;

fn main() {
    let list = vec![1, 2, 3];
    println!("Before defining closure: {list:?}");

    thread::spawn(move || println!("From thread: {list:?}"))
        .join()
        .unwrap();
}
```

We spawn a new thread, giving the thread a closure to run as an argument. The closure body prints out the list. In Listing 13-4, the closure only captured `list` using an immutable reference because that’s the least amount of access to `list` needed to print it. In this example, even though the closure body still only needs an immutable reference, we need to specify that `list` should be moved into the closure by putting the `move` keyword at the beginning of the closure definition. The new thread might finish before the rest of the main thread finishes, or the main thread might finish first. If the main thread maintained ownership of `list` but ended before the new thread did and dropped `list`, the immutable reference in the thread would be invalid. Therefore, the compiler requires that `list` be moved into the closure given to the new thread so the reference will be valid.
#### Moving captured values out of closures and the `Fn` traits
Once a closure has captured a reference or captured ownership of a value from the environment where the closure is defined (thus affecting what, if anything, is moved _into_ the closure), the code in the body of the closure defines what happens to the references or values when the closure is evaluated later (thus affecting what, if anything, is moved _out of_ the closure). A closure body can do any of the following: move a captured value out of the closure, mutate the captured value, neither move nor mutate the value, or capture nothing from the environment to begin with.

The way a closure captures and handles values from the environment affects which traits the closure implements, and traits are how functions and structs can specify what kinds of closures they can use. Closures will automatically implement one, two, or all three of these `Fn` traits, in an additive fashion, depending on how the closure’s body handles the values:

1. `FnOnce` applies to closures that can be called once. All closures implement at least this trait, because all closures can be called. A closure that moves captured values out of its body will only implement `FnOnce` and none of the other `Fn` traits, because it can only be called once.
2. `FnMut` applies to closures that don’t move captured values out of their body, but that might mutate the captured values. These closures can be called more than once.
3. `Fn` applies to closures that don’t move captured values out of their body and that don’t mutate captured values, as well as closures that capture nothing from their environment. These closures can be called more than once without mutating their environment, which is important in cases such as calling a closure multiple times concurrently.

Let’s look at the definition of the `unwrap_or_else` method on `Option<T>` that we used below.

```rust
impl<T> Option<T> {
    pub fn unwrap_or_else<F>(self, f: F) -> T
    where
        F: FnOnce() -> T
    {
        match self {
            Some(x) => x,
            None => f(),
        }
    }
}
```

Recall that `T` is the generic type representing the type of the value in the `Some` variant of an `Option`. That type `T` is also the return type of the `unwrap_or_else` function: code that calls `unwrap_or_else` on an `Option<String>`, for example, will get a `String`.

Next, notice that the `unwrap_or_else` function has the additional generic type parameter `F`. The `F` type is the type of the parameter named `f`, which is the closure we provide when calling `unwrap_or_else`.

The trait bound specified on the generic type `F` is `FnOnce() -> T`, which means `F` must be able to be called once, take no arguments, and return a `T`. Using `FnOnce` in the trait bound expresses the constraint that `unwrap_or_else` is only going to call `f` at most one time. In the body of `unwrap_or_else`, we can see that if the `Option` is `Some`, `f` won’t be called. If the `Option` is `None`, `f` will be called once. Because all closures implement `FnOnce`, `unwrap_or_else` accepts all three kinds of closures and is as flexible as it can be.

**Note**: Functions can implement all three of the `Fn` traits too. If what we want to do doesn’t require capturing a value from the environment, we can use the name of a function rather than a closure where we need something that implements one of the `Fn` traits. For example, on an `Option<Vec<T>>` value, we could call `unwrap_or_else(Vec::new)` to get a new, empty vector if the value is `None`.
#### Closures must name captured lifetimes
When you start designing functions that accept or return closures, you’ll need to think about the lifetime of data captured by the closure. For example, here is a simple program that is supposed to return a closure that clones a string:

```rust
fn make_a_cloner(s_ref: &str) -> impl Fn() -> String {
    move || s_ref.to_string()
}
```

However, this program is rejected by the compiler with the following error:

```text
error[E0700]: hidden type for `impl Fn() -> String` captures lifetime that does not appear in bounds
 --> test.rs:2:5
  |
1 | fn make_a_cloner(s_ref: &str) -> impl Fn() -> String {
  |                         ---- hidden type `[closure@test.rs:2:5: 2:12]` captures the anonymous lifetime defined here
2 |     move || s_ref.to_string()
  |     ^^^^^^^^^^^^^^^^^^^^^^^^^
```

This error might be a bit confusing. What is a hidden type? Why does it capture a lifetime? Why does that lifetime need to appear in a bound?

To answer those questions, let’s start by seeing what would happen if Rust allowed `make_a_cloner` to compile. Then we could write the following unsafe program:

![[Pasted image 20240910132820.png]]

Let’s follow the execution. After calling `make_a_cloner(&s_own)`, at L1 we get back a closure `cloner`. Within the closure is its environment, the reference `s_ref`. However, if we are allowed to drop `s_own` at L2, then that invalidates `cloner` because its environment contains a pointer to deallocated memory. Then invoking `cloner()` would cause a use-after-free.

Returning to the original type error, the issue is that **we need to tell Rust that the closure returned from `make_a_cloner` must not live longer than `s_ref`.** We can do that explicitly using a lifetime parameter like this:

```rust
//              vvvv         vv                             vvvv                
fn make_a_cloner<'a>(s_ref: &'a str) -> impl Fn() -> String + 'a {
    move || s_ref.to_string()
}
```

These changes say: `s_ref` is a string reference that lives for `'a`. Adding `+ 'a` to the return type’s trait bounds indicates that the closure must live no longer than `'a`. Therefore Rust deduces this function is now safe. If we try to use it unsafely like before:

![[Pasted image 20240910132920.png]]

Rust recognizes that as long as `make_a_cloner` is in use, `s_own` cannot be dropped. This is reflected in the permissions: `s_own` loses the O permission after calling `make_a_cloner`. Consequently, Rust rejects this program with the following error:

```text
error[E0505]: cannot move out of `s_own` because it is borrowed
  --> test.rs:9:6
   |
8  | let cloner = make_a_cloner(&s_own);
   |                            ------ borrow of `s_own` occurs here
9  | drop(s_own);
   |      ^^^^^ move out of `s_own` occurs here
10 | cloner();
   | ------ borrow later used here
```

Returning now to the original confusing error: the “hidden type” of the closure captured `s_ref` which had a limited lifetime. The return type never mentioned this lifetime, so Rust could not deduce that `make_a_cloner` was safe. But if we explicitly say that the closure captures the lifetime of `s_ref`, then our function compiles.

Note that we can use the [lifetime elision](https://rust-book.cs.brown.edu/ch10-03-lifetime-syntax.html#lifetime-elision) rules to make the function type more concise. We can remove the `<'a>` generic so long as we keep an indicator that the returned closure depends on _some_ lifetime, like this:

```rust
fn make_a_cloner(s_ref: &str) -> impl Fn() -> String + '_ {
    move || s_ref.to_string()
}
```

In sum, the `Fn` traits are important when defining or using functions or types that make use of closures. In the next section, we’ll discuss iterators. Many iterator methods take closure arguments, so keep these closure details in mind as we continue!