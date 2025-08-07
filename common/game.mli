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
  tax_rate : float;
  score : int;
  daily_cost : int;
  small_cost : int;
  medium_cost : int;
  high_cost : int;
  ultra_high_cost : int;
  flood_queue : Position.t list option;
  flooded_tiles : Position.t list;
  current_goal : Goal.t option;
  completed_goals : string list;
}
[@@deriving sexp, equal]



val new_game : unit -> t

val place_building :
  t -> position:Position.t -> building:Building.t -> (t, string) result

val tutorial_placement :
  t -> position:Position.t -> building:Building.t -> (t, string) result

val remove_building : t -> position:Position.t -> (t, string) result
val get_building : t -> position:Position.t -> Building.t option
val update_happy_rate : g:t -> rate_change:int -> t
val update_population_rate : g:t -> rate_change:int -> t
val update_money_rate : g:t -> rate_change:int -> t
val end_tutorial : t -> t
val game_over : t -> t
val enact_policy : policy:Policy.t -> game:t -> (t, string) result
val start_day : t -> (t * Position.t list option) * string option
val get_feedback_categories : t -> Public_feedback.feedback_category list
val tick : t -> (t, string) result
val implement_policy : t -> Policy.t -> (t, string) result
val remove_policy : t -> Policy.t -> (t, string) result
val print_game : t -> unit
val add_mandatory : position:Position.t -> t -> (t, string) result
val all_mandatory_placed : t -> bool
val burn_buildings : Position.t list -> t -> t
val collect_reward_function : t -> t
