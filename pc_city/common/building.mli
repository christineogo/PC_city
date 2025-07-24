open! Core

type t = Police | Electricity | School | Fire | House
[@@deriving sexp_of, equal, bin_io, enumerate]

include Comparable.S_binable with type t := t

val of_string : string -> t
val to_string : t -> string
