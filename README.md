# fmt

[![Package Version](https://img.shields.io/hexpm/v/fmt)](https://hex.pm/packages/fmt)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/fmt/)

Type-safe (string) formatting for Gleam.

Heavily inspired by ["Type-safe functional formatted IO"](https://okmij.org/ftp/typed-formatting/index.html) by Oleg Kiselyov.

## Usage

The following code would print out `Movie: Inside Out; Rating: 5; Price: $24.99`:

```gleam
import fmt
import gleam/io

// This will print out "Movie: Inside Out; Rating: 5; Price: $24.99"
pub fn main() {
  fmt.lit("Movie: ")
  |> fmt.cat(fmt.string())
  |> fmt.cat(fmt.lit("; Rating: "))
  |> fmt.cat(fmt.int())
  |> fmt.cat(fmt.lit("; Price: $"))
  |> fmt.cat(fmt.float())
  |> fmt.sprintf3("Inside Out", 5, 24.99)
  |> io.println
}
```

In this example, 

- `lit` is used to specify literal string values.
- `string` is used to specify a `String` placeholder.
- `int` is used to specify an `Int` placeholder.
- `float` is used to specify a `Float` placeholder.
- `cat` is used to concatenate the formatting specifications.
- `sprintf3` is used to generate the string from the given specification.

For more details and examples, see the documentation and the tests.

### Type Safety

It is **type-safe**: the compiler will ensure that you have set everything up correctly, both in terms of the number of expected arguments and their types.

Check out this example:

```gleam
pub fn will_fail() {
  fmt.lit("Name: ")
  |> fmt.cat(fmt.string())
  |> fmt.cat(fmt.lit("; Age: "))
  |> fmt.cat(fmt.int())
  |> fmt.sprintf2("Juan", "Carlos")
}
```

If you were to check this with `gleam check`, you would get an error something like this:

```
error: Type mismatch
   ┌─ ./fmt/test/fmt_test.gleam:82:27
   │
82 │   |> fmt.sprintf2("Juan", "Carlos")
   │                           ^^^^^^^^

Expected type:

    Int

Found type:

    String
```

## See also

There are a couple other Gleam formatting libraries that I am aware of.  You may be interested in them as well!

*Note: The following example code blocks are taken from the respective project READMEs.*

### Glormat

[Glormat](https://github.com/SaphiraKai/glormat) provides a readable style of format strings, and a pipeline-based API.

```gleam
import gleam/io
import glormat.{assert_ok, replace, then, then_debug}

pub fn main() {
  "hello {object}, the {operation} is {result}"
    |> replace("object", with: "world")
    |> then("operation", with: "sum")
    |> then_debug("result", with: 1 + 2)
    |> assert_ok
    |> io.println // hello world, the sum is 3
}
```

### Sprinkle

[Sprinkle](https://github.com/LilyRose2798/sprinkle) uses readable format strings and uses string tuples to specify replacements.

```gleam
import sprinkle.{format}

pub fn main() {
  let output = format("My name is {name} and I like to do {activity}!", [
    #("name", "Lily"),
    #("activity", "programming")
  ])
}
```

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/gleam_qcheck)

Copyright (c) 2024 Ryan M. Moore

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.

