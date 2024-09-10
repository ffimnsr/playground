Rusty
=====


Creating new project using Cargo

~~~
cargo new hello_cargo --bin       --> create binary application project
cargo new hello                   --> create library
cargo build                       --> build the project
cargo build --release             --> build for release
cargo run                         --> run the executable
cargo update                      --> update packages
cargo doc --open                  --> build documentation and open in browser
~~~

The package manager in rust is called `cargo` on which it fetch cargo packages from [Crates.io](http://crates.io)

**Note**: Rust macros have `!` at the end of statement like this `println!`.

Creating mutable and immutable variables

~~~
let foo = 5;                      --> immutable
let mut bar = 5;                  --> mutable
~~~

The `&` indicates that the argument is a *reference*, which gives you a way to let multiple parts of code access one piece of data without needing to copy that data into memory multiple times.

~~~
io::stdin().read_line(&mut guess)
  .expect("Failed to read line")
~~~

In the example above where using `&mut guess` instead of `&guess` to make it mutable.

~~~
println!("You guessed: {}", guess);
~~~

The set `{}` is a placeholder that holds a value in place.

~~~
let mut guess = String::new();

io::stdin().read_line(&mut guess)
  .expect("Failed to read the line");

let guess: u32 = guess.trim().parse()
  .expect("Please type a number!");
~~~

Rust allows shadowing and lets us reuse the `guess` variable rather than forcing us to create two unique variables, like `guess_str` and `guess`. The difference between `mut` and shadowing is that because we're effectively creating a new variable when we use the `let` keyword again, we can change the type of the value, but reuse the same name.

The `const` keyword are hardcoded values and can be used throughout your program. Constants can be declared in any scope, including global scope. Also, constants aren't immutable by default, they're always immutable.

Rust is a statically typed language, meaning it must know the types of all variables at compile time. The compiler can usually infer what type we want to use based on the value and how we use it.

Scalar Types
------------

A scalar type represents a single value.

~~~
i8 i16 i32 i64 isize       --> signed
u8 u16 u32 u64 usize       --> unsigned
f32 f64                    --> floating point
bool                       --> boolean
char                       --> character
~~~

Compount Types
--------------

Compound types can group multiple values of other types into one.

~~~
let tup: (i32, f64, u8) = (500, 6.4, 1);                  --> tuple
let (x, y, z) = tup;                                      --> destructuring a tuple
let five_hundred = tup.0;                                 --> another way of destructuring a tuple and access it
let a = [1, 2, 3];                                        --> array
let first = a[0];                                         --> accessing an array
~~~

Functions
---------

Functions are pervasive in Rust. Rust code uses *snake case* as the conventional style for functions and variable names. In snake case, all letters are lowercase and underscores separate words.

~~~
fn another_function() {                                   --> a function
  ... code ...
}

fn another_function(x: i32) {                             --> function with argument
  ... code ...
}

fn five() -> i32 {                                        --> function with return values
  5
}
~~~

In a function with return value, you can return early by using `return` keyword and specifying a value.

Expressions evaluate to something. Below is an expression that assigns the result to `y`. Expressions do not include ending semicolons. If you add semicolon to the end of an expression, you turn it into a statement, which will then not return value.

~~~
let y = {
  let x = 3;
  x + 1
};
~~~

Control Flows
-------------

Control flow are statements that lets the system run depending on condition.

~~~
if number < 5 {                                           --> if statement
  ... code ...
} else if number > 5 {
  ... code ...
} else {
  ... code ...
}

let five = if condition {                                 --> if and let statement
  5
}
~~~

The `loop` keyword tells Rust to execute a block of code over and over again forever or until you explicitly tell it to stop.

~~~
loop {
  ... code ...
}
~~~

The `while` loop is often useful for a program to evaluate a condition within the loop.

~~~
while number != 0 {
  ... code ...
}
~~~

The `for` loop iterates over a certain enumerable.

~~~
let a = [10, 20, 30];
for el in a.iter() {
  ... code ...
}

for number in (1..4).rev() {
  ... code ...
}
~~~

The `rev` is to reverse the range.

Creating String type in rust differs from string literal. String literals are convenient, but they aren't always suitable for every situation in which you want to use text. One reason is that they're immutable. For this purpose rust has a second string type, `String`. This type is allocated on the heap and such is able to store an amount of text that is unknown to us at compile time. To create a `String` from a string literal check below.

~~~
let s = String::from("hello");
s.push_str(", world!");                               --> appends a literal to a String
~~~

To free memory instanly from using `String` one must call `drop` similar to RAII of C++. Otherwise Rust will automatically call `drop` at the end of closing tag or scope.

A `String` is made up of three parts, a pointer to the memory that holds the contents of the string, a length, and a capacity. So if we assign the String and set it to another variable, we copy the pointer, length, and capacity.

~~~
let s1 = String::from("hello");
let s2 = s1;
~~~

In the example above Rust tends to remove the ownership of s1 and move it to s2 to avoid `double free` error. As freeing memory twice can lead to memory corruption, which can potentially lead to security vulnerabilities. The examples above invalidates s1. Rust will never automatically create "deep" copies of data. Therefore, automatic copying can be assumed to be inexpensive in terms of runtime performance.

So if we do want deeply copy of data of the String, not just the stack data, we can use common method called `clone`.

~~~
let s1 = String::from("hello");
let s2 = s1.clone();
~~~

Rust on string has ownership so if we tend to pass `String` variable to a function it will automatically goes out of scope.

~~~
fn main() {
  let s1 = String::from("hello");
  take_ownership(s);                            --> s values moves into the function and so is no longer valid.
}

take_ownership(s: String) {
  ... code ...
}
~~~

Taking and giving back ownership of `String` also in other terms way of transferring

~~~
fn main() {
  let s1 = String::from("hello");
  let s2 = takes_and_gives_back(s1);
}

fn takes_and_gives_back(s: String) -> String {
  s
}
~~~

In order to bypass above and still use s1 variable one must use *references*. The ampersands are *references*, and they allow you to refer to some value without taking ownership of it.

~~~
fn main() {
  let s1 = String::from("hello");
  let len = get_length(&s1);
}

fn get_length(s: &String) -> usize {
  s.len()                                                         --> accessing the borrowed data.
}
~~~

The opposite of referencing by using `&` is dereferencing, which is accomplished with the dereference operator, `*`. And we call having references as function parameters *borrowing*. But attempting to modify a borrowed value will cause errors. To fix this we can call `mut`.

~~~
fn main() {
  let s1 = String::from("hello");
  change(&mut s1);
}

fn change(s: &mut String) -> usize {
  s.push_str(", world!");
}
~~~

But mutable references have one big restriction, you can only have one mutable reference to a particular piece of data in a particular scope.
In Rust, by contrast the compiler guarantees that references will never be dangling references, see below example that will **error**.

~~~
fn main() {
    let reference_to_nothing = dangle();
}

fn dangle() -> &String {
    let s = String::from("hello");
    &s
}
~~~

Rules of references, can only have one mutable, and any number of immutable references. Always references must be valid.

Slices is another data type that does not have ownership. Slices let you reference a contigouus sequence of elements in a collection rather than the whole section.

~~~
fn first_word(s: &String) -> usize {
  let bytes = s.as_bytes();
  for (i, &item) in bytes.iter().enumerate() {
    if item == b' ' {
      return i;
    }
  }
  s.len
}
~~~

A string slices is a reference to part of `String`. We can create slices using a range within a brackets by specifying `[start..end]`. On the range one can omit the start or end or both to specify the whole string.

~~~
let s = String::from("hello world");
let hello = &s[0..5];
let world = &s[6..11];
~~~

Structs
-------

Structs are similar to tuples. But unlike tuples, the piece of struct can have names.

~~~
struct User {
  username: String,
  email: String,
  active: bool,
}

let user1 = User {                                          --> immutable struct
  username: String::from("..."),
  email: String::from("..."),
  active: true,
};

let mut user2 = User {                                      --> mutable struct
  username: String::from("..."),
  email: String::from("..."),
  active: true,
};
user2.email = String::from("...");

let user3 = User {
  username: String::from("..."),
  email: String::from("..."),
  ..user1                                                   --> create instances from other instances with struct update syntax
}

struct Color(i32, i32, i32);                                --> tuple struct, values can be accessed using `.` and index
~~~

Unit-like structs are empty structs, useful in situations such as when you need to implement trait in some type.

~~~
struct Ball()
~~~

Method are similar to functions, however methods are different from functions in that they're defined within the context of a struct, and their first parameter is always `self`, which represents the instance of the struct the method is being called on.

~~~
struct Rectangle {
  width: u32,
  height: u32,
}

impl Rectangle {
  fn area(&self) -> u32 {
    self.width * self.height
  }
}

fn main() {
  let rect1 = Rectangle { width: 30, height: 50 };
  let area = rect1.area();
}
~~~

In Rust what is equivalent of `object->something()` in C++ is `(*object).something()`. But Rust has a feature called automatic referencing and dereferencing means Rust automatically adds in `&`, `&mut`, or `*` so object matches signature of the method. In other words both of the example below is the same.

~~~
p1.distance(&p2);
(&p1).distance(&p2);
~~~

Associated functions is another useful feature of `impl` blocks. Means we're allowed to define functions within `impl` blocks that don't take `self` as parameter. Sample of it is `String::from`

~~~
impl Rectangle {
  fn square(size: u32) -> Rectangle {
    Rectangle { width: size, height: size }
  }
}

let sq = Rectangle::square(3);
~~~

Also, each struct is allowed to have multiple `impl` blocks and there's no reason to separate this methods but kind of just a valid syntax.

Enums can be useful when one needs to enumerate. One more similarity between enums and structs is using `impl` to create methods.

~~~
enum IpAddrKind {
  V4,
  V6,
}
let four = IpAddrKind::V4;
~~~

The `Option` Enum has alot of advantage over null values. Look below for the implementation of it in the standard library.

~~~
enum Option<T> {
  Some(T),
  None,
}
let absent_number: Option<i32> = None;
~~~

The `match` syntax allows us to compare a value against a series of patterns and then execute code.

~~~
match somevalue {
  1 => ... code ...
  _ => ()                           --> placeholder to catch all value and `()` is unit value so nothing will happen
}
~~~

For the above situation we can just use `if let`. In other words, you can think of if let as syntax sugar for a `match` that runs code when the value matches one pattern and then ignores all other values.

~~~
if let 1 = somevalue {
  ... code ...
}
~~~

A module or `mod` is a namespace that contains definitions of functions or types, and you can choose whether those definitions are visible outside their module or not. By default functions, types, constants, and modules are private. The `pub` keyword makes an item public. The `use` keyword brings modules, or the definitions inside modueles, into scope.

~~~
mod tests {
  fn it_works() {
    ... code ...
  }
}

pub mod show_tests {
  pub fn show_it_works() {
    ... code ...
  }
}
~~~

Referring to different modules can be done using `use` keyword.

~~~
use series::of;
use series::of::nested_modules;
use lights::{Red, Yellow};
use shapes::*;

fn main() {
  of::nested_modules();
  nested_modules();

  let red = Red;
  let yellow = Yellow;
  let circle = Circle;                                      --> use glob `*` in use
}
~~~

Accessing the parent module can also be done using `super` keyword

~~~
::client::connect();                                        --> start from root
super::client::connect();                                   --> move up one module in the hierarchy
~~~

