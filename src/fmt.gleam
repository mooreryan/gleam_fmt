//// This module provides functions for creating formatting specifications and 
//// generating strings from those specificaitons in a type-safe way.
//// 
//// ## Overview
////
//// - Functions to build basic formatting specifications
////     - `lit`: for literal strings
////     - `bool`: for `Bool` values
////     - `float`: for `Float` values
////     - `int`: for `Int` values
////     - `string`: for `String` values
////     - `a`: for custom types and compound data types
//// - The `cat` function is used to concatenate formatting specifications.
//// - The `sprintf` function, and its variants `sprintf1`, `sprintf2`, etc., are
//// used to generate strings from formatting specifications.
//// 
//// For additional information, check out the examples provided in this 
//// module's documentation, as well as those in the README and the tests, which
//// can be found in the project repository.
//// 
//// *Note: The examples in this file use functions from the gleeunit package 
//// for illustration.*

import gleam/bool
import gleam/float
import gleam/int

/// `Fmt` is an opaque type that represents a formatting specification.
pub opaque type Fmt(a, b) {
  Fmt(fn(fn(String) -> a) -> b)
}

/// `lit(str)` returns a format specification for the literal string value 
/// provided by the argument `str`.
/// 
/// ```gleam
/// import fmt
/// import gleeunit/should
/// 
/// pub fn lit_test() {
///   fmt.lit("Hello, Gleam!")
///   |> fmt.sprintf
///   |> should.equal("Hello, Gleam!")
/// }
/// ```
/// 
pub fn lit(str: String) -> Fmt(a, a) {
  Fmt(fn(k) { k(str) })
}

/// `bool()` returns a format specification for a boolean value.  You could
/// think of this as a placeholder that must be filled with a value of the type
/// `Bool`.
/// 
pub fn bool() -> Fmt(a, fn(Bool) -> a) {
  Fmt(fn(k) { fn(x) { k(bool.to_string(x)) } })
}

/// `float()` returns a format specification for a floating-point value.  You
/// could think of this as a placeholder that must be filled with a value of the
/// type `Float`.
/// 
pub fn float() -> Fmt(a, fn(Float) -> a) {
  Fmt(fn(k) { fn(x) { k(float.to_string(x)) } })
}

/// `int()` returns a format specification for an integer value.  You could
/// think of this as a placeholder that must be filled with a value of the type
/// `Int`.
/// 
pub fn int() -> Fmt(a, fn(Int) -> a) {
  Fmt(fn(k) { fn(x) { k(int.to_string(x)) } })
}

/// `string()` returns a format specification for a string value.  You could
/// think of this as a placeholder that must be filled with a value of the type
/// `String`.
/// 
pub fn string() -> Fmt(a, fn(String) -> a) {
  Fmt(fn(k) { fn(x) { k(x) } })
}

/// `a(show)` returns a format specification for a value of type `a` 
/// given a function `show` that converts values of type `a` to values of type
/// `String`.
/// 
/// This is useful for formatting custom types or other compound data types.
/// 
/// Here is an example of formatting an integer list (`List(Int)`):
/// 
/// ```gleam
/// import fmt
/// import gleam/int
/// import gleam/list
/// import gleam/string
/// import gleeunit/should
/// 
/// pub fn formatting_int_list_test() {
///   let show_list = fn(lst) {
///     lst
///     |> list.map(int.to_string)
///     |> string.join(with: "; ")
///   }
///
///   fmt.lit("[")
///   |> fmt.cat(fmt.a(show_list))
///   |> fmt.cat(fmt.lit("]"))
///   |> fmt.sprintf1([1, 2, 3])
///   |> should.equal("[1; 2; 3]")
/// }
/// ```
/// 
/// Here is an example of formatting a custom data type:
/// 
/// ```gleam
/// import fmt
/// import gleam/float
/// import gleam/int
/// import gleam/list
/// import gleam/string
/// import gleeunit/should
/// 
/// type Either(a, b) {
///   First(a)
///   Second(b)
/// }
/// 
/// fn either_to_string(
///   either: Either(a, b),
///   a_to_string: fn(a) -> String,
///   b_to_string: fn(b) -> String,
/// ) -> String {
///   case either {
///     First(a) -> "First: " <> a_to_string(a)
///     Second(b) -> "Second: " <> b_to_string(b)
///   }
/// }
/// 
/// pub fn formatting_custom_types_test() {
///   fmt.lit("Which is it? ")
///   |> fmt.cat(fmt.a(show: either_to_string(_, int.to_string, float.to_string)))
///   |> fmt.sprintf1(Second(2.71828))
///   |> should.equal("Which is it? Second: 2.71828")
/// }
/// ```
/// 
pub fn a(show show: fn(a) -> String) -> Fmt(b, fn(a) -> b) {
  Fmt(fn(k) { fn(x) { k(show(x)) } })
}

/// `cat(fmt_left, fmt_right)` concatenates the two formatting specifications.  
/// This is the way to combine little formatting specifications into one big 
/// formatting specification.  You would normally compose these with the pipe 
/// `(|>)`.
/// 
/// ```gleam
/// import fmt
/// import gleeunit/should
/// 
/// pub fn cat_test() {
///   fmt.lit("Name: ")
///   |> fmt.cat(fmt.string())
///   |> fmt.cat(fmt.lit("; Age: "))
///   |> fmt.cat(fmt.int())
///   |> fmt.sprintf2("Juan", 45)
///   |> should.equal("Name: Juan; Age: 45")
/// }
/// ```
/// 
pub fn cat(fmt_left: Fmt(a, b), fmt_right: Fmt(c, a)) -> Fmt(c, b) {
  let Fmt(fmt_left) = fmt_left
  let Fmt(fmt_right) = fmt_right

  Fmt(
    // This is the continuation
    fn(k) {
      // The left (first) Fmt function
      fmt_left(
        // The left Fmt function's continuation
        fn(str1) {
          // The right (second) Fmt function.
          fmt_right(
            // The right Fmt function's continuation.
            fn(str2) {
              // Finally, call the continuation with the concatenation
              // of the two strings.
              k(str1 <> str2)
            },
          )
        },
      )
    },
  )
}

// }
/// `sprintf(fmt)` takes a formatting specification and returns a curried 
/// function for generating the specified string.
/// 
/// You likely use the `sprintfN` variants of this function rather than this 
/// one, as those eliminate the need to work with the curried functions.
/// 
/// Here is an example. I have annotated some of the types, which may clarify 
/// some things.
/// 
/// ```gleam
/// pub fn sprintf_test() {
///   let fmt: fmt.Fmt(String, fn(String) -> fn(Int) -> fn(Bool) -> String) =
///     fmt.lit("Name: ")
///     |> fmt.cat(fmt.string())
///     |> fmt.cat(fmt.lit("; Age: "))
///     |> fmt.cat(fmt.int())
///     |> fmt.cat(fmt.lit("; Acct. Active: "))
///     |> fmt.cat(fmt.bool())
///
///   let f: fn(String) -> fn(Int) -> fn(Bool) -> String = fmt.sprintf(fmt)
///
///   f("Juan")(45)(True)
///   |> should.equal("Name: Juan; Age: 45; Acct. Active: True")
/// ```
/// 
/// Alternatively, you may rather use the `uncurry` function with the matching arity so that you can continue the pipeline.
/// 
/// ```gleam
/// pub fn sprintf_uncurry_test() {
///   fmt.lit("Name: ")
///   |> fmt.cat(fmt.string())
///   |> fmt.cat(fmt.lit("; Age: "))
///   |> fmt.cat(fmt.int())
///   |> fmt.cat(fmt.lit("; Acct. Active: "))
///   |> fmt.cat(fmt.bool())
///   |> fmt.sprintf
///   |> fmt.uncurry3("Juan", 45, True)
///   |> should.equal("Name: Juan; Age: 45; Acct. Active: True")
/// }
/// ```
pub fn sprintf(fmt: Fmt(String, a)) -> a {
  let Fmt(fmt) = fmt

  fmt(fn(x) { x })
}

/// `sprintf1(fmt, x1)` takes a formatting specification `fmt` and a value `x1`, 
/// and returns the specified string with the appropriate placeholders filled by
/// the given values.
/// 
pub fn sprintf1(fmt: Fmt(String, fn(a) -> b), x1: a) -> b {
  sprintf(fmt)(x1)
}

/// `sprintf2(fmt, x1, x2)` takes a formatting specification `fmt` and two
/// values `x1` and `x2`, and returns the specified string with the appropriate
/// placeholders filled by the given values.
/// 
pub fn sprintf2(fmt: Fmt(String, fn(a) -> fn(b) -> c), x1: a, x2: b) -> c {
  sprintf(fmt)(x1)(x2)
}

/// `sprintf3(fmt, x1, x2, x3)` takes a formatting specification `fmt` and three
/// values `x1`, `x2`, and `x3`, and returns the specified string with the
/// appropriate placeholders filled by the given values.
/// 
pub fn sprintf3(
  fmt: Fmt(String, fn(a) -> fn(b) -> fn(c) -> d),
  x1: a,
  x2: b,
  x3: c,
) -> d {
  sprintf(fmt)(x1)(x2)(x3)
}

/// `sprintf4(fmt, x1, x2, x3, x4)` takes a formatting specification `fmt` and
/// four values `x1`, `x2`, `x3`, and `x4`, and returns the specified string
/// with the appropriate placeholders filled by the given values.
/// 
pub fn sprintf4(
  fmt: Fmt(String, fn(a) -> fn(b) -> fn(c) -> fn(d) -> e),
  x1: a,
  x2: b,
  x3: c,
  x4: d,
) -> e {
  sprintf(fmt)(x1)(x2)(x3)(x4)
}

/// `sprintf5(fmt, x1, x2, x3, x4, x5)` takes a formatting specification `fmt`
/// and five values `x1`, `x2`, `x3`, `x4`, and `x5`, and returns the specified
/// string with the appropriate placeholders filled by the given values.
pub fn sprintf5(
  fmt: Fmt(String, fn(a) -> fn(b) -> fn(c) -> fn(d) -> fn(e) -> f),
  x1: a,
  x2: b,
  x3: c,
  x4: d,
  x5: e,
) -> f {
  sprintf(fmt)(x1)(x2)(x3)(x4)(x5)
}

/// `sprintf6(fmt, x1, x2, x3, x4, x5, x6)` takes a formatting specification
/// `fmt` and six values `x1`, `x2`, `x3`, `x4`, `x5`, and `x6`, and returns
/// the specified string with the appropriate placeholders filled by the given
/// values.
/// 
pub fn sprintf6(
  fmt: Fmt(String, fn(a) -> fn(b) -> fn(c) -> fn(d) -> fn(e) -> fn(f) -> g),
  x1: a,
  x2: b,
  x3: c,
  x4: d,
  x5: e,
  x6: f,
) -> g {
  sprintf(fmt)(x1)(x2)(x3)(x4)(x5)(x6)
}

/// `sprintf7(fmt, x1, x2, x3, x4, x5, x6, x7)` takes a formatting specification
/// `fmt` and seven values `x1`, `x2`, `x3`, `x4`, `x5`, `x6`, and `x7`, and
/// returns the specified string with the appropriate placeholders filled by the
/// given values.
/// 
pub fn sprintf7(
  fmt: Fmt(
    String,
    fn(a) -> fn(b) -> fn(c) -> fn(d) -> fn(e) -> fn(f) -> fn(g) -> h,
  ),
  x1: a,
  x2: b,
  x3: c,
  x4: d,
  x5: e,
  x6: f,
  x7: g,
) -> h {
  sprintf(fmt)(x1)(x2)(x3)(x4)(x5)(x6)(x7)
}

/// `sprintf8(fmt, x1, x2, x3, x4, x5, x6, x7, x8)` takes a formatting
/// specification `fmt` and eight values `x1`, `x2`, `x3`, `x4`, `x5`, `x6`,
/// `x7`, and `x8`, and returns the specified string with the appropriate
/// placeholders filled by the given values.
/// 
pub fn sprintf8(
  fmt: Fmt(
    String,
    fn(a) -> fn(b) -> fn(c) -> fn(d) -> fn(e) -> fn(f) -> fn(g) -> fn(h) -> i,
  ),
  x1: a,
  x2: b,
  x3: c,
  x4: d,
  x5: e,
  x6: f,
  x7: g,
  x8: h,
) -> i {
  sprintf(fmt)(x1)(x2)(x3)(x4)(x5)(x6)(x7)(x8)
}

/// `sprintf9(fmt, x1, x2, x3, x4, x5, x6, x7, x8, x9)` takes a formatting
/// specification `fmt` and nine values `x1`, `x2`, `x3`, `x4`, `x5`, `x6`,
/// `x7`, `x8`, and `x9`, and returns the specified string with the appropriate
/// placeholders filled by the given values.
/// 
pub fn sprintf9(
  fmt: Fmt(
    String,
    fn(a) ->
      fn(b) -> fn(c) -> fn(d) -> fn(e) -> fn(f) -> fn(g) -> fn(h) -> fn(i) -> j,
  ),
  x1: a,
  x2: b,
  x3: c,
  x4: d,
  x5: e,
  x6: f,
  x7: g,
  x8: h,
  x9: i,
) -> j {
  sprintf(fmt)(x1)(x2)(x3)(x4)(x5)(x6)(x7)(x8)(x9)
}

/// `uncurry2(f, x1, x2)` takes a curried function `f` and two arguments `x1`
/// and `x2`, and returns the result of applying the function `f` to the 
/// arguments.
/// 
/// This is useful for continuing a pipeline when using the curried version of 
/// `sprintf`.
/// 
pub fn uncurry2(f: fn(a) -> fn(b) -> c, x1: a, x2: b) -> c {
  f(x1)(x2)
}

/// `uncurry3(f, x1, x2, x3)` takes a curried function `f` and three arguments
/// `x1`, `x2`, and `x3`, and returns the result of applying the function `f` to
/// the arguments.
/// 
/// This is useful for continuing a pipeline when using the curried version of
/// `sprintf`.
pub fn uncurry3(f: fn(a) -> fn(b) -> fn(c) -> d, x1: a, x2: b, x3: c) -> d {
  f(x1)(x2)(x3)
}

/// `uncurry4(f, x1, x2, x3, x4)` takes a curried function `f` and four
/// arguments `x1`, `x2`, `x3`, and `x4`, and returns the result of applying
/// the function `f` to the arguments.
/// 
/// This is useful for continuing a pipeline when using the curried version of
/// `sprintf`.
/// 
pub fn uncurry4(
  f: fn(a) -> fn(b) -> fn(c) -> fn(d) -> e,
  x1: a,
  x2: b,
  x3: c,
  x4: d,
) -> e {
  f(x1)(x2)(x3)(x4)
}

/// `uncurry5(f, x1, x2, x3, x4, x5)` takes a curried function `f` and five
/// arguments `x1`, `x2`, `x3`, `x4`, and `x5`, and returns the result of
/// applying the function `f` to the arguments.
/// 
/// This is useful for continuing a pipeline when using the curried version of
/// `sprintf`.
/// 
pub fn uncurry5(
  f: fn(a) -> fn(b) -> fn(c) -> fn(d) -> fn(e) -> f,
  x1: a,
  x2: b,
  x3: c,
  x4: d,
  x5: e,
) -> f {
  f(x1)(x2)(x3)(x4)(x5)
}

/// `uncurry6(f, x1, x2, x3, x4, x5, x6)` takes a curried function `f` and six
/// arguments `x1`, `x2`, `x3`, `x4`, `x5`, and `x6`, and returns the result of
/// applying the function `f` to the arguments.
/// 
/// This is useful for continuing a pipeline when using the curried version of
/// `sprintf`.
/// 
pub fn uncurry6(
  f: fn(a) -> fn(b) -> fn(c) -> fn(d) -> fn(e) -> fn(f) -> g,
  x1: a,
  x2: b,
  x3: c,
  x4: d,
  x5: e,
  x6: f,
) -> g {
  f(x1)(x2)(x3)(x4)(x5)(x6)
}

/// `uncurry7(f, x1, x2, x3, x4, x5, x6, x7)` takes a curried function `f` and
/// seven arguments `x1`, `x2`, `x3`, `x4`, `x5`, `x6`, and `x7`, and returns
/// the result of applying the function `f` to the arguments.
/// 
/// This is useful for continuing a pipeline when using the curried version of
/// `sprintf`.
/// 
pub fn uncurry7(
  f: fn(a) -> fn(b) -> fn(c) -> fn(d) -> fn(e) -> fn(f) -> fn(g) -> h,
  x1: a,
  x2: b,
  x3: c,
  x4: d,
  x5: e,
  x6: f,
  x7: g,
) -> h {
  f(x1)(x2)(x3)(x4)(x5)(x6)(x7)
}

/// `uncurry8(f, x1, x2, x3, x4, x5, x6, x7, x8)` takes a curried function `f`
/// and eight arguments `x1`, `x2`, `x3`, `x4`, `x5`, `x6`, `x7`, and `x8`, and
/// returns the result of applying the function `f` to the arguments.
/// 
/// This is useful for continuing a pipeline when using the curried version of
/// `sprintf`.
/// 
pub fn uncurry8(
  f: fn(a) -> fn(b) -> fn(c) -> fn(d) -> fn(e) -> fn(f) -> fn(g) -> fn(h) -> i,
  x1: a,
  x2: b,
  x3: c,
  x4: d,
  x5: e,
  x6: f,
  x7: g,
  x8: h,
) -> i {
  f(x1)(x2)(x3)(x4)(x5)(x6)(x7)(x8)
}

/// `uncurry9(f, x1, x2, x3, x4, x5, x6, x7, x8, x9)` takes a curried function
/// `f` and nine arguments `x1`, `x2`, `x3`, `x4`, `x5`, `x6`, `x7`, `x8`, and
/// `x9`, and returns the result of applying the function `f` to the arguments.
/// 
/// This is useful for continuing a pipeline when using the curried version of
/// `sprintf`.
/// 
pub fn uncurry9(
  f: fn(a) ->
    fn(b) -> fn(c) -> fn(d) -> fn(e) -> fn(f) -> fn(g) -> fn(h) -> fn(i) -> j,
  x1: a,
  x2: b,
  x3: c,
  x4: d,
  x5: e,
  x6: f,
  x7: g,
  x8: h,
  x9: i,
) -> j {
  f(x1)(x2)(x3)(x4)(x5)(x6)(x7)(x8)(x9)
}
