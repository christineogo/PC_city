open! Core

type t = Police | Electricity | Fire | House | University | School | Grocery | Retail | Apartment | Greenspace
[@@deriving sexp, equal, bin_io, enumerate]

include Comparable.S_binable with type t := t

val of_string : string -> t
val to_string : t -> string
