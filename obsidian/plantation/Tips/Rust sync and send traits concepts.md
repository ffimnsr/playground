Rust language has _very_ few concurrency features. Almost every concurrency feature we’ve talked about so far in this chapter has been part of the standard library, not the language. Your options for handling concurrency are not limited to the language or the standard library; you can write your own concurrency features or use those written by others.

However, two concurrency concepts are embedded in the language: the `std::marker` traits `Sync` and `Send`.
#### Allowing transference of ownership between threads with `Send`
The `Send` marker trait indicates that ownership of values of the type implementing `Send` can be transferred between threads. Almost every Rust type is `Send`, but there are some exceptions, including `Rc<T>`: this cannot be `Send` because if you cloned an `Rc<T>` value and tried to transfer ownership of the clone to another thread, both threads might update the reference count at the same time. For this reason, `Rc<T>` is implemented for use in single-threaded situations where you don’t want to pay the thread-safe performance penalty.

Therefore, Rust’s type system and trait bounds ensure that you can never accidentally send an `Rc<T>` value across threads unsafely. 

Any type composed entirely of `Send` types is automatically marked as `Send` as well. Almost all primitive types are `Send`, aside from raw pointers.
#### Allowing access from multiple threads with `Sync`
The `Sync` marker trait indicates that it is safe for the type implementing `Sync` to be referenced from multiple threads. In other words, any type `T` is `Sync` if `&T` (an immutable reference to `T`) is `Send`, meaning the reference can be sent safely to another thread. Similar to `Send`, primitive types are `Sync`, and types composed entirely of types that are `Sync` are also `Sync`.

`Sync` is the most similar concept in Rust to the colloquial meaning of the phrase “thread-safe”, i.e. that a particular piece of data can be safely used by multiple concurrent threads. The reason for having separate `Send` and `Sync` traits is that a type can sometimes be one, or both, or neither. For example:

- The smart pointer `Rc<T>` is also neither `Send` nor `Sync`, for reasons described above.
- The `RefCell<T>` type and the family of related `Cell<T>` types are `Send` (if `T: Send`), but they are not `Sync`. A `RefCell` can be sent across a thread boundary, but not accessed concurrently because the implementation of borrow checking that `RefCell<T>` does at runtime is not thread-safe.
- The smart pointer `Mutex<T>` is `Send` and `Sync`, and can be used to share access with multiple threads.
- The type `MutexGuard<'a, T>` that is returned by `Mutex::lock` is `Sync` (if `T: Sync`) but not `Send`. It is specifically not `Send` because [some platforms mandate that mutexes are unlocked by the same thread that locked them](https://github.com/rust-lang/rust/issues/23465#issuecomment-82730326).
#### Implementing `Send` and `Sync` manually is unsafe
Because types that are made up of `Send` and `Sync` traits are automatically also `Send` and `Sync`, we don’t have to implement those traits manually. As marker traits, they don’t even have any methods to implement. They’re just useful for enforcing invariants related to concurrency.

Manually implementing these traits involves implementing unsafe Rust code. The important information is that building new concurrent types not made up of `Send` and `Sync` parts requires careful thought to uphold the safety guarantees. [“The Rustonomicon”](https://doc.rust-lang.org/nomicon/index.html) has more information about these guarantees and how to uphold them.
