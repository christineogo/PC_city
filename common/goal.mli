open! Core

type t = {
  id : string;
  description : string;
  reward: int;
}
[@@deriving sexp, equal]
val all : t list