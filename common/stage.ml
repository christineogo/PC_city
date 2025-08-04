open! Core

type t = Tutorial | Game_continues | Game_over | Win [@@deriving sexp, equal]
