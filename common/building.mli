open! Core

type t = Police | Electricity | Fire | House | University | School | Grocery | Retail | Apartment | Greenspace | Water | Hospital 
[@@deriving sexp, equal, bin_io, enumerate]

include Comparable.S_binable with type t := t

val colors: (string * t)list 
val of_string : string -> t
val to_string : t -> string
val get_color : t -> string 
