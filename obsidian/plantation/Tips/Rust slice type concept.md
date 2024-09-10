_Slices_ let you reference a contiguous sequence of elements in a [collection](https://rust-book.cs.brown.edu/ch08-00-common-collections.html) rather than the whole collection. A slice is a kind of reference, so it is a non-owning pointer.

To motivate why slices are useful, let’s work through a small programming problem: write a function that takes a string of words separated by spaces and returns the first word it finds in that string. If the function doesn’t find a space in the string, the whole string must be one word, so the entire string should be returned. Without slices, we might write the signature of the function like this:

```rust
fn first_word(s: &String) -> ?
```

The `first_word` function has a `&String` as a parameter. We don’t want ownership of the string, so this is fine. But what should we return? We don’t really have a way to talk about _part_ of a string. However, we could return the index of the end of the word, indicated by a space.

```rust
fn first_word(s: &String) -> usize {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return i;
        }
    }

    s.len()
}
```

Because we need to go through the `String` element by element and check whether a value is a space, we’ll convert our `String` to an array of bytes using the `as_bytes` method:

```rust
    let bytes = s.as_bytes();
```

Next, we create an iterator over the array of bytes using the `iter` method:

```rust
    for (i, &item) in bytes.iter().enumerate() {
```

For now, know that `iter` is a method that returns each element in a collection and that `enumerate` wraps the result of `iter` and returns each element as part of a tuple instead. The first element of the tuple returned from `enumerate` is the index, and the second element is a reference to the element. This is a bit more convenient than calculating the index ourselves.

Because the `enumerate` method returns a tuple, we can use patterns to destructure that tuple. In the `for` loop, we specify a pattern that has `i` for the index in the tuple and `&item` for the single byte in the tuple. Because we get a reference to the element from `.iter().enumerate()`, we use `&` in the pattern.

Inside the `for` loop, we search for the byte that represents the space by using the byte literal syntax. If we find a space, we return the position. Otherwise, we return the length of the string by using `s.len()`:

```rust
        if item == b' ' {
            return i;
        }
    }

    s.len()
```

We now have a way to find out the index of the end of the first word in the string, but there’s a problem. We’re returning a `usize` on its own, but it’s only a meaningful number in the context of the `&String`. In other words, because it’s a separate value from the `String`, there’s no guarantee that it will still be valid in the future.

![[Pasted image 20240910102444.png]]

This program compiles without any errors, as `s` retains write permissions after calling `first_word`. Because `word` isn’t connected to the state of `s` at all, `word` still contains the value `5`. We could use that value `5` with the variable `s` to try to extract the first word out, but this would be a bug because the contents of `s` have changed since we saved `5` in `word`.

Having to worry about the index in `word` getting out of sync with the data in `s` is tedious and error prone! Managing these indices is even more brittle if we write a `second_word` function. Its signature would have to look like this:

```rust
fn second_word(s: &String) -> (usize, usize) {
```

Now we’re tracking a starting _and_ an ending index, and we have even more values that were calculated from data in a particular state but aren’t tied to that state at all. We have three unrelated variables floating around that need to be kept in sync.

Luckily, Rust has a solution to this problem: string slices.
#### String slices
A _string slice_ is a reference to part of a `String`, and it looks like this:

![[Pasted image 20240910102734.png]]

Rather than a reference to the entire `String` (like `s2`), `hello` is a reference to a portion of the `String`, specified in the extra `[0..5]` bit. We create slices using a range within brackets by specifying `[starting_index..ending_index]`, where `starting_index` is the first position in the slice and `ending_index` is one more than the last position in the slice.

Slices are special kinds of references because they are “fat” pointers, or pointers with metadata. Here, the metadata is the length of the slice. We can see this metadata by changing our visualization to peek into the internals of Rust’s data structures:

![[Pasted image 20240910102826.png]]

Observe that the variables `hello` and `world` have both a `ptr` and a `len` field, which together define the underlined regions of the string on the heap. You can also see here what a `String` actually looks like: a string is a vector of bytes (`Vec<u8>`), which contains a length `len` and a buffer `buf` that has a pointer `ptr` and a capacity `cap`.

Because slices are references, they also change the permissions on referenced data. For example, observe below that when `hello` is created as a slice of `s`, then `s` loses write and own permissions:

![[Pasted image 20240910103007.png]]
#### Range syntax
With Rust’s `..` range syntax, if you want to start at index zero, you can drop the value before the two periods. In other words, these are equal:

```rust
let s = String::from("hello");

let slice = &s[0..2];
let slice = &s[..2];
```

You can also drop both values to take a slice of the entire string. So these are equal:

```rust
let s = String::from("hello");

let len = s.len();

let slice = &s[0..len];
let slice = &s[..];
```

Note: String slice range indices must occur at valid UTF-8 character boundaries. If you attempt to create a string slice in the middle of a multibyte character, your program will exit with an error.
#### Rewriting `first_word` with string slices

With all this information in mind, let’s rewrite `first_word` to return a slice. The type that signifies “string slice” is written as `&str`:

```rust
fn first_word(s: &String) -> &str {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }

    &s[..]
}
```

We get the index for the end of the word in the same way, by looking for the first occurrence of a space. When we find a space, we return a string slice using the start of the string and the index of the space as the starting and ending indices.

Now when we call `first_word`, we get back a single value that is tied to the underlying data. The value is made up of a reference to the starting point of the slice and the number of elements in the slice.

Returning a slice would also work for a `second_word` function:

```rust
fn second_word(s: &String) -> &str {
```

We now have a straightforward API that’s much harder to mess up, because the compiler will ensure the references into the `String` remain valid.
#### String literals are slices
Recall that we talked about string literals being stored inside the binary. Now that we know about slices, we can properly understand string literals:

```rust
let s = "Hello, world!";
```

The type of `s` here is `&str`: it’s a slice pointing to that specific point of the binary. This is also why string literals are immutable; `&str` is an immutable reference.
#### String slices as parameters
Knowing that you can take slices of literals and `String` values leads us to one more improvement on `first_word`, and that’s its signature:

```rust
fn first_word(s: &String) -> &str {
```

A more experienced Rustacean would write the signature instead because it allows us to use the same function on both `&String` values and `&str` values.

```rust
fn first_word(s: &str) -> &str {
```

If we have a string slice, we can pass that directly. If we have a `String`, we can pass a slice of the `String` or a reference to the `String`. This flexibility takes advantage of _deref coercions_. Defining a function to take a string slice instead of a reference to a `String` makes our API more general and useful without losing any functionality.
#### Other slices
String slices, as you might imagine, are specific to strings. But there’s a more general slice type, too. Consider this array:

```rust
let a = [1, 2, 3, 4, 5];
```

Just as we might want to refer to a part of a string, we might want to refer to part of an array. We’d do so like this:

```rust
let a = [1, 2, 3, 4, 5];

let slice = &a[1..3];

assert_eq!(slice, &[2, 3]);
```

This slice has the type `&[i32]`. It works the same way as string slices do, by storing a reference to the first element and a length. You’ll use this kind of slice for all sorts of other collections.
#### Summary
Slices are a special kind of reference that refer to sub-ranges of a sequence, like a string or a vector. At runtime, a slice is represented as a “fat pointer” which contains a pointer to the beginning of the range and a length of the range. One advantage of slices over index-based ranges is that the slice cannot be invalidated while it’s being used.
