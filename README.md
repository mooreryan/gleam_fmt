# fmt

Type-safe (string) formatting for Gleam.

Heavily inspired by ["Type-safe functional formatted IO"](https://okmij.org/ftp/typed-formatting/index.html) by Oleg Kiselyov.

## Example Usage

The following code would print out `Movie: Inside Out; Rating: 5; Price: $24.99`:

```gleam
import fmt
import gleam/io

// This will print out "Movie: Inside Out; Rating: 5; Price: 13.99"
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

Further examples can be found in the documentation and in the `test` directory.

## Development

```sh
gleam test  # Run the tests
```
