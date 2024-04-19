import fmt
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import gleeunit/should

pub fn readme_test() {
  fmt.lit("Movie: ")
  |> fmt.cat(fmt.string())
  |> fmt.cat(fmt.lit("; Rating: "))
  |> fmt.cat(fmt.int())
  |> fmt.cat(fmt.lit("; Price: $"))
  |> fmt.cat(fmt.float())
  |> fmt.sprintf3("Inside Out", 5, 24.99)
  |> should.equal("Movie: Inside Out; Rating: 5; Price: $24.99")
}

pub fn lit_test() {
  fmt.lit("Hello, Gleam!")
  |> fmt.sprintf
  |> should.equal("Hello, Gleam!")
}

pub fn formatting_int_list_test() {
  let show_list = fn(lst) {
    lst
    |> list.map(int.to_string)
    |> string.join(with: "; ")
  }

  fmt.lit("[")
  |> fmt.cat(fmt.a(show_list))
  |> fmt.cat(fmt.lit("]"))
  |> fmt.sprintf1([1, 2, 3])
  |> should.equal("[1; 2; 3]")
}

type Either(a, b) {
  First(a)
  Second(b)
}

fn either_to_string(
  either: Either(a, b),
  a_to_string: fn(a) -> String,
  b_to_string: fn(b) -> String,
) -> String {
  case either {
    First(a) -> "First: " <> a_to_string(a)
    Second(b) -> "Second: " <> b_to_string(b)
  }
}

pub fn formatting_custom_types_test() {
  fmt.lit("Which is it? ")
  |> fmt.cat(fmt.a(show: either_to_string(_, int.to_string, float.to_string)))
  |> fmt.sprintf1(Second(2.71828))
  |> should.equal("Which is it? Second: 2.71828")
}

pub fn cat_test() {
  fmt.lit("Name: ")
  |> fmt.cat(fmt.string())
  |> fmt.cat(fmt.lit("; Age: "))
  |> fmt.cat(fmt.int())
  |> fmt.sprintf2("Juan", 45)
  |> should.equal("Name: Juan; Age: 45")
}

pub fn sprintf_test() {
  let fmt: fmt.Fmt(String, fn(String) -> fn(Int) -> fn(Bool) -> String) =
    fmt.lit("Name: ")
    |> fmt.cat(fmt.string())
    |> fmt.cat(fmt.lit("; Age: "))
    |> fmt.cat(fmt.int())
    |> fmt.cat(fmt.lit("; Acct. Active: "))
    |> fmt.cat(fmt.bool())

  let f: fn(String) -> fn(Int) -> fn(Bool) -> String = fmt.sprintf(fmt)

  f("Juan")(45)(True)
  |> should.equal("Name: Juan; Age: 45; Acct. Active: True")
}

pub fn sprintf_uncurry_test() {
  fmt.lit("Name: ")
  |> fmt.cat(fmt.string())
  |> fmt.cat(fmt.lit("; Age: "))
  |> fmt.cat(fmt.int())
  |> fmt.cat(fmt.lit("; Acct. Active: "))
  |> fmt.cat(fmt.bool())
  |> fmt.sprintf
  |> fmt.uncurry3("Juan", 45, True)
  |> should.equal("Name: Juan; Age: 45; Acct. Active: True")
}
