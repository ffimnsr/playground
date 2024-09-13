Pin exists to solve a very specific problem: self-referential datatypes, i.e. data structures which have pointers into themselves. For example, a binary search tree might have self-referential pointers, which point to other nodes in the same struct.

Self-referential types can be really useful, but they're also hard to make memory-safe.

Rust types fall into two categories.

1. Types that are safe to move around in memory. This is the default, the norm. For example, this includes primitives like numbers, strings, bools, as well as structs or enums entirely made of them. Most types fall into this category!
2. Self-referential types, which are _not_ safe to move around in memory. These are pretty rare. An example is the [intrusive linked list inside some Tokio internals](https://docs.rs/tokio/1.10.0/src/tokio/util/linked_list.rs.html). Another example is most types which implement Future and also borrow data, for reasons [explained in the Rust async book](https://rust-lang.github.io/async-book/04_pinning/01_chapter.html).

Types in category (1) are totally safe to move around in memory. You won't invalidate any pointers by moving them around. But if you move a type in (2), then you invalidate pointers and can get undefined behaviour.

Any type in (1) implements a special auto trait called [`Unpin`](https://doc.rust-lang.org/stable/std/marker/trait.Unpin.html).

Types in (2) are creatively named `!Unpin` (the `!` in a trait means "does not implement"). To use these types safely, we can't use regular pointers for self-reference. Instead, we use special pointers that "pin" their values into place, ensuring they can't be moved. This is exactly what the [`Pin`](https://doc.rust-lang.org/stable/std/pin/struct.Pin.html) type does.

Pin wraps a pointer and stops its value from moving. The only exception is if the value impls `Unpin` -- then we know it's safe to move.
#### Summary
If a Rust type has self-referential pointers, it can't be moved safely. After all, moving doesn't update the pointers, so they'll still be pointing at the old memory address, so they're now invalid. Rust can automatically tell which types are safe to move (and will auto impl the `Unpin` trait for them). If you have a `Pin`-ned pointer to some data, Rust can guarantee that nothing unsafe will happen (if it's safe to move, you can move it, if it's unsafe to move, then you can't). This is important because many Future types are self-referential, so we need `Pin` to safely poll a Future.