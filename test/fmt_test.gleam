import fmt
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn kitchen_sink_test() {
  fmt.lit("Fmt: ")
  |> fmt.cat(fmt.bool())
  |> fmt.cat(fmt.lit(", "))
  |> fmt.cat(fmt.float())
  |> fmt.cat(fmt.lit(", "))
  |> fmt.cat(fmt.int())
  |> fmt.cat(fmt.lit(", "))
  |> fmt.cat(fmt.string())
  |> fmt.cat(fmt.lit("."))
  |> fmt.sprintf4(True, 2.71828, 47, "Hello")
  |> should.equal("Fmt: True, 2.71828, 47, Hello.")
}

pub fn curried_sprintf_test() {
  let format_print =
    fmt.lit("Movie: ")
    |> fmt.cat(fmt.string())
    |> fmt.cat(fmt.lit("; Rating: "))
    |> fmt.cat(fmt.int())
    |> fmt.cat(fmt.lit("; Price: "))
    |> fmt.cat(fmt.float())

  fmt.sprintf(format_print)("Inside Out")(5)(13.99)
  |> should.equal("Movie: Inside Out; Rating: 5; Price: 13.99")
}

pub fn formatting_variants_test() {
  // Uses the sprintf internally here ase well. May want to use
  // regular string concatenation in this case.
  let result_to_string = fn(res) {
    case res {
      Ok(n) ->
        fmt.lit("Ok(")
        |> fmt.cat(fmt.int())
        |> fmt.cat(fmt.lit(")"))
        |> fmt.sprintf1(n)
      Error(s) ->
        fmt.lit("Error(")
        |> fmt.cat(fmt.string())
        |> fmt.cat(fmt.lit(")"))
        |> fmt.sprintf1(s)
    }
  }

  fmt.lit("Result: ")
  |> fmt.cat(fmt.a(show: result_to_string))
  |> fmt.sprintf1(Ok(11))
  |> should.equal("Result: Ok(11)")

  fmt.lit("Result: ")
  |> fmt.cat(fmt.a(show: result_to_string))
  |> fmt.sprintf1(Error("oops"))
  |> should.equal("Result: Error(oops)")
}

// This is the example from the readme.
pub fn readme_example_test() {
  fmt.lit("Movie: ")
  |> fmt.cat(fmt.string())
  |> fmt.cat(fmt.lit("; Rating: "))
  |> fmt.cat(fmt.int())
  |> fmt.cat(fmt.lit("; Price: $"))
  |> fmt.cat(fmt.float())
  |> fmt.sprintf3("Inside Out", 5, 24.99)
  |> should.equal("Movie: Inside Out; Rating: 5; Price: $24.99")
}
