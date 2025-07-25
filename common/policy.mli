open! Core

type t = Clean_Energy | Education | Disable_Mandatory
[@@deriving sexp, equal]

(* val policy_effect : policy:t -> game:Game.t -> Game.t *)
