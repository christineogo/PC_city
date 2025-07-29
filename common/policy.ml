open! Core

type t = Clean_Energy | Education | Disable_Mandatory | Increase_Occupancy
[@@deriving sexp, equal]

let of_string string = 
    match string with
    |"Clean Energy" -> Clean_Energy
    |"Improve Education" -> Education
    |"Increase Housing Occupancy" -> Increase_Occupancy
    |"Defund Mandatory Services" -> Disable_Mandatory
    |_ -> Education
(*     
    Fn.compose t_of_sexp Sexp.of_string *)
let to_string = Fn.compose Sexp.to_string_hum sexp_of_t
(* 
let policy_effect ~policy ~game =
  match policy with
  | Education -> Game.update_happy_rate game (Int.min 100 game.happy_rate + 10)
  | Clean_Energy ->
      Game.update_happy_rate game (Int.min 100 game.happy_rate + 10)
  | Disable_Mandatory ->
      Game.update_happy_rate game (Int.min 100 game.happy_rate + 10) *)
