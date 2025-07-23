open! Core

type t =
  | Illegal_move
  | Game_continues
  | Game_over
[@@deriving sexp_of]
