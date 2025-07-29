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
}
[@@deriving sexp, equal]


let new_game () =
  {
    game_stage = Stage.Tutorial;
    board = Position.Map.empty;
    building_counts = Building.Map.empty;
    implemented_policies = [];
    population = 0;
    money = 1000;
    happiness = 0;
    population_rate = 0;
    money_rate = 0;
    happy_rate = 0;
    current_day = 0;
    tax_rate = 0.0;
  }

let print_game game = 
  print_s[%message (game:t)]
(* placing structures *)
let get_building t ~position = Map.find t.board position

let dup_mandatory t ~building =
  let mandatory_buildings =
    [ Building.Electricity; Building.Fire; Building.Police ]
  in
  if not (List.exists mandatory_buildings ~f:(Building.equal building)) then
    false
  else
    match Map.find t.building_counts building with Some 1 -> true | _ -> false

let place_building t ~position ~building =
  if dup_mandatory t ~building then
    Error "You cannot place multiple mandatory buildings"
  else if Position.in_bounds position then
    if Map.mem t.board position then Error "already a building here" else
    let board = Map.set t.board ~key:position ~data:building in
    let building_counts =
      Map.update t.building_counts building ~f:(function
        | None -> 1
        | Some count -> count + 1)
    in
    Ok { t with board; building_counts }
  else Error "position is out of bounds"

let tutorial_placement t ~position ~building =
  let mandatory_buildings =
    [ Building.Electricity; Building.Fire; Building.Police ]
  in
  if not (List.exists mandatory_buildings ~f:(Building.equal building)) then
    Error "You can only place mandatory buildings in the tutorial"
  else place_building t ~position ~building

let remove_building t ~position =
  match Map.find t.board position with
  | None -> Error "there is no building to remove at this location"
  | Some building ->
      let board = Map.remove t.board position in
      let building_counts =
        Map.update t.building_counts building ~f:(function
          | None -> 0
          | Some count when count > 1 -> count - 1
          | Some _ -> 0)
      in
      Ok { t with board; building_counts }



(* internal state updating *)
let update_happy_rate (g : t) (new_rate : int) : t =
  { g with happy_rate = new_rate }

let update_population_rate (g : t) (new_rate : int) : t =
  { g with population_rate = new_rate }

let update_money_rate (g : t) (new_rate : int) : t =
  { g with money_rate = new_rate }




let end_tutorial (g : t) = { g with game_stage = Stage.Game_continues }
let game_over (g : t) = { g with game_stage = Stage.Game_over }

let update_stats game =
  {
    game with
    money = game.money + game.money_rate;
    happiness = Int.min 100 (game.happiness + game.happy_rate);
    population = game.population + game.population_rate;
  }

(* policies and effects *)
let policy_effect ~policy ~game =
  match policy with
  | Policy.Education -> update_happy_rate game (Int.min 100 game.happy_rate + 10)
  | Policy.Clean_Energy ->
      update_happy_rate game (Int.min 100 game.happy_rate + 10)
  | Policy.Disable_Mandatory ->
      update_happy_rate game (Int.min 100 game.happy_rate + 10)
  | _ -> game


let fire_event game =
  print_endline "A fire has hit your town!";
  game
  (* {
    game with
    population = Float.to_int (Int.to_float game.population *. 0.85);
    money = Float.to_int (Int.to_float game.money *. 0.85);
    happiness = Int.max 0 game.happiness - 10;
  } *)

let protest_event game =
  print_endline "Your residents are protesting!";
  game
  (* {
    game with
    population = game.population - 10;
    happiness = Int.max 0 game.happiness - 5;
  } *)

let robbery_event game =
  print_endline "Robberies have struck your town!";
  game
  (* {
    game with
    money = Float.to_int (Int.to_float game.money *. 0.75);
    happiness = Int.max 0 game.happiness - 5;
  } *)

let get_robbery_risk game =
  let robbery_risk = 1 in
  if
    List.exists game.implemented_policies ~f:(fun policy ->
        Policy.equal policy Policy.Disable_Mandatory)
  then robbery_risk * 2
  else robbery_risk

let get_fire_risk game =
  let fire_risk = 1 in
  if
    List.exists game.implemented_policies ~f:(fun policy ->
        Policy.equal policy Policy.Disable_Mandatory)
  then fire_risk * 2
  else fire_risk

let get_protest_risk game =
  let protest_risk = 1 in
  if
    List.exists game.implemented_policies ~f:(fun policy ->
        Policy.equal policy Policy.Clean_Energy)
  then protest_risk * 1
  else protest_risk

let implement_policy game policy = 
  if List.exists game.implemented_policies ~f:(fun item ->
        Policy.equal item policy)
        then Error "You have already implemented this policy!"
  else Ok {game with implemented_policies = List.append game.implemented_policies [policy]}

let remove_policy game policy =
  if List.exists game.implemented_policies ~f:(fun item ->
        Policy.equal item policy)
        then Ok {game with implemented_policies = (List.filter game.implemented_policies ~f:(fun item -> not (Policy.equal item policy)))}
  else Error "You cannot remove a policy you haven't implemented"

let daily_events game =
  (* CR: Might want to make the possible event for that day chosen randomly from the list instead *)
  let robbery_risk = get_robbery_risk game in
  let fire_risk = get_fire_risk game in
  let protest_risk = get_protest_risk game in
  if (robbery_risk * Random.int 100) > 99 then Some Event.Robbery
  else if (fire_risk * Random.int 100) > 99 then Some Event.Fire
  else if (protest_risk * Random.int 100) > 99 then Some Event.Protest
  else None

  (*
let get_public_opinion_categories (g : t) : Public_feedback.feedback_category list =
  let cats = ref [] in
  if List.exists g.implemented_policies ~f:(Policy.equal Policy.Disable_Mandatory) then
    cats := Defund_mandatory :: !cats;
  
let random_element lst =
  match lst with
  | [] -> None
  | _ -> Some (List.nth_exn lst (Random.int (List.length lst)))

let get_public_opinion_messages (g : t) : string list =
  get_public_opinion_categories g
  |> List.filter_map ~f:(fun cat ->
      Public_feedback.get_feedback_for_category cat |> random_element
    )
*)

(* time passing *)
let start_day game =
  print_endline("possible event");
  match daily_events game with
  | Some Event.Robbery -> robbery_event game
  | Some Event.Fire -> fire_event game
  | Some Event.Protest -> protest_event game
  | None -> game

let tick game =
  print_endline("new day started");
  print_s [%message (game.current_day:int)];
  let updated_game = update_stats game in
  let new_day =
    { updated_game with current_day = updated_game.current_day + 1 }
  in
  if new_day.happiness < 0 then Error "Game over! Happiness has reached 0"
  else if new_day.money < 0 then Error "Game over! Money has reached 0"
  else if new_day.population < 0 then
    Error "Game over! Population has reached 0"
  else 
    Ok new_day

let add_mandatory ~position game = 
  let mandatory_buildings =
    [ Building.Electricity; Building.Fire; Building.Police ] in
  let next_mandatory = List.filter mandatory_buildings ~f:(fun item -> not (dup_mandatory game ~building:item)) in
  if not (List.is_empty next_mandatory) then 
    place_building game ~position ~building: (List.hd_exn next_mandatory)
else Ok (end_tutorial game)

