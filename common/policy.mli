open! Core

type t = Clean_Energy | Education | Disable_Mandatory| Increase_Occupancy
[@@deriving sexp, equal]

val of_string : string -> t
val to_string : t -> string

(* val policy_effect : policy:t -> game:Game.t -> Game.t *)
