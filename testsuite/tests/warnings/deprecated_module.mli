[@@@travlang.deprecated {|
  As you could guess, Deprecated_module is deprecated.
  Please use something else!
|} ]

module M: sig
  val x: int
    [@@travlang.deprecated]

  type t
    [@@travlang.deprecated]
end
[@@travlang.deprecated]
