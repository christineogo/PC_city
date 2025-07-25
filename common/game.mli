open! Core

type t = {
  game_stage : Stage.t;
  board : Building.t Position.Map.t;
  building_counts : int Building.Map.t;
  implemented_policies : Policy.t list;
  population : int;
  money : int;
  happiness : int;
  population_rate : int;
  money_rate : int;
  happy_rate : int;
  current_day : int;
}
[@@deriving sexp_of, equal]

val new_game : unit -> t

val place_building :
  t -> position:Position.t -> building:Building.t -> (t, string) result

val tutorial_placement :
  t -> position:Position.t -> building:Building.t -> (t, string) result

val remove_building : t -> position:Position.t -> (t, string) result
val get_building : t -> position:Position.t -> Building.t option
val update_happy_rate : t -> int -> t
val update_population_rate : t -> int -> t
val update_money_rate : t -> int -> t
val end_tutorial : t -> t
val game_over : t -> t
val policy_effect : policy:Policy.t -> game:t -> t
val start_day : t -> t
val tick : t -> (t, string) result

val implement_policy : t -> Policy.t -> (t, string) result
val remove_policy : t -> Policy.t -> (t, string) result