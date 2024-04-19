import gleam/bool
import gleam/float
import gleam/int

pub type Fmt(a, b) {
  Fmt(fn(fn(String) -> a) -> b)
}

pub fn lit(str: String) -> Fmt(a, a) {
  Fmt(fn(k) { k(str) })
}

pub fn bool() -> Fmt(a, fn(Bool) -> a) {
  Fmt(fn(k) { fn(x) { k(bool.to_string(x)) } })
}

pub fn float() -> Fmt(a, fn(Float) -> a) {
  Fmt(fn(k) { fn(x) { k(float.to_string(x)) } })
}

pub fn int() -> Fmt(a, fn(Int) -> a) {
  Fmt(fn(k) { fn(x) { k(int.to_string(x)) } })
}

pub fn string() -> Fmt(a, fn(String) -> a) {
  Fmt(fn(k) { fn(x) { k(x) } })
}

// TODO: Maybe call it `val`?
pub fn a(show show: fn(a) -> String) -> Fmt(b, fn(a) -> b) {
  Fmt(fn(k) { fn(x) { k(show(x)) } })
}

pub fn cat(
  format_print_left: Fmt(a, b),
  format_print_right: Fmt(c, a),
) -> Fmt(c, b) {
  let Fmt(fp_left) = format_print_left
  let Fmt(fp_right) = format_print_right

  Fmt(
    // This is the continuation
    fn(k) {
      // The left (first) Fmt function
      fp_left(
        // The left Fmt function's continuation
        fn(str1) {
          // The right (second) Fmt function.
          fp_right(
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

pub fn sprintf(fmt: Fmt(String, a)) -> a {
  let Fmt(fmt) = fmt

  fmt(fn(x) { x })
}

pub fn sprintf1(fmt: Fmt(String, fn(a) -> b), x1: a) -> b {
  sprintf(fmt)(x1)
}

pub fn sprintf2(fmt: Fmt(String, fn(a) -> fn(b) -> c), x1: a, x2: b) -> c {
  sprintf(fmt)(x1)(x2)
}

pub fn sprintf3(
  fmt: Fmt(String, fn(a) -> fn(b) -> fn(c) -> d),
  x1: a,
  x2: b,
  x3: c,
) -> d {
  sprintf(fmt)(x1)(x2)(x3)
}

pub fn sprintf4(
  fmt: Fmt(String, fn(a) -> fn(b) -> fn(c) -> fn(d) -> e),
  x1: a,
  x2: b,
  x3: c,
  x4: d,
) -> e {
  sprintf(fmt)(x1)(x2)(x3)(x4)
}

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

pub fn uncurry2(f: fn(a) -> fn(b) -> c, x1: a, x2: b) -> c {
  f(x1)(x2)
}

pub fn uncurry3(f: fn(a) -> fn(b) -> fn(c) -> d, x1: a, x2: b, x3: c) -> d {
  f(x1)(x2)(x3)
}

pub fn uncurry4(
  f: fn(a) -> fn(b) -> fn(c) -> fn(d) -> e,
  x1: a,
  x2: b,
  x3: c,
  x4: d,
) -> e {
  f(x1)(x2)(x3)(x4)
}

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
