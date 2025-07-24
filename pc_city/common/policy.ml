open! Core

type t = Clean_Energy | Education | Disable_Mandatory
[@@deriving sexp_of, equal]
(* 
let policy_effect ~policy ~game =
  match policy with
  | Education -> Game.update_happy_rate game (Int.min 100 game.happy_rate + 10)
  | Clean_Energy ->
      Game.update_happy_rate game (Int.min 100 game.happy_rate + 10)
  | Disable_Mandatory ->
      Game.update_happy_rate game (Int.min 100 game.happy_rate + 10) *)
