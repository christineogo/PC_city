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
    money = 5000;
    happiness = 0;
    population_rate = 0;
    money_rate = 0;
    happy_rate = 0;
    current_day = 0;
    tax_rate = 0.0;
  }

let daily_cost = -50
let small_cost = -100
let medium_cost = -250
let high_cost = -500
let _ultra_high_cost = -750

let get_money_change building =
  match building with
  | Building.Police ->
      daily_cost
      (* (match game.game_stage with 
      |Stage.Tutorial -> 0
      |_ -> -10
      ) *)
  | Electricity ->
      daily_cost
      (* (match game.game_stage with 
      |Stage.Tutorial -> 0
      |_ -> -10
      ) *)
  | Fire -> daily_cost
  | House -> 0
  | University -> daily_cost
  | School -> daily_cost
  | Grocery -> -small_cost
  | Retail -> -small_cost
  | Apartment -> 0
  | Greenspace -> 0
  | Water ->
      daily_cost
      (* (match game.game_stage with 
      |Stage.Tutorial -> 0
      |_ -> -10
      ) *)
  | Hospital -> daily_cost
(* (match game.game_stage with 
      |Stage.Tutorial -> 0
      |_ -> -10
      ) *)

let building_cost building =
  match building with
  | Building.Police -> 0
  | Electricity -> 0
  | Fire -> 0
  | House -> small_cost
  | University -> high_cost
  | School -> medium_cost
  | Grocery -> medium_cost
  | Retail -> medium_cost
  | Apartment -> high_cost
  | Greenspace -> daily_cost
  | Water -> 0
  | Hospital -> 0

let get_population_change building =
  match building with
  | Building.House -> 4
  | Apartment -> 30
  | School -> 0
  | Grocery -> 0
  | _ -> 0

let print_game game = print_s [%message (game : t)]

(* internal state updating *)
let update_happy_rate ~(g : t) ~(rate_change : int) : t =
  { g with happy_rate = rate_change + g.happy_rate }

let update_population_rate ~(g : t) ~(rate_change : int) : t =
  { g with population_rate = rate_change + g.population_rate }

let update_money_rate ~(g : t) ~(rate_change : int) : t =
  { g with money_rate = rate_change + g.money_rate }

let update_stats_from_building ~building ~game =
  let new_game =
    { game with population = game.population + get_population_change building }
  in
  let building_cost_game =
    { new_game with money = game.money + building_cost building }
  in
  update_money_rate ~g:building_cost_game
    ~rate_change:(get_money_change building)

(* placing structures *)
let get_building t ~position = Map.find t.board position

let dup_mandatory t ~building =
  let mandatory_buildings =
    [ Building.Electricity; Water; Police; Hospital; Fire ]
  in
  if not (List.exists mandatory_buildings ~f:(Building.equal building)) then
    false
  else
    match Map.find t.building_counts building with Some 1 -> true | _ -> false

let place_building t ~position ~building =
  if dup_mandatory t ~building then
    Error "You cannot place multiple mandatory buildings"
  else if Position.in_bounds position then
    if Map.mem t.board position then Error "already a building here"
    else
      let board = Map.set t.board ~key:position ~data:building in
      let building_counts =
        Map.update t.building_counts building ~f:(function
          | None -> 1
          | Some count -> count + 1)
      in
      let new_game = { t with board; building_counts } in
      Ok (update_stats_from_building ~game:new_game ~building)
  else Error "position is out of bounds"

let tutorial_placement t ~position ~building =
  let mandatory_buildings =
    [ Building.Electricity; Water; Police; Hospital; Fire ]
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

let end_tutorial (g : t) = { g with game_stage = Stage.Game_continues }
let game_over (g : t) = { g with game_stage = Stage.Game_over }

let update_stats game =
  print_s
    [%message
      (Float.to_int (game.tax_rate *. Int.to_float game.population) : int)];
  {
    game with
    money =
      game.money + game.money_rate
      + Float.to_int (game.tax_rate *. Int.to_float game.population /. 10.);
    happiness = Int.min 100 (game.happiness + game.happy_rate);
    population = game.population + game.population_rate;
  }

(* policies and effects *)
let enact_policy ~policy ~game =
  match List.mem game.implemented_policies policy ~equal:Policy.equal with 
  | true -> Error "You have already implemented this policy"
  | false ->(
  let new_game = {game with implemented_policies = List.append game.implemented_policies [policy]} in
  (match policy with
  | Policy.Education ->
      Ok (update_happy_rate ~g:new_game
        ~rate_change:(Int.min (100 - new_game.happy_rate) 10))
  | Clean_Energy ->
      Ok (update_happy_rate ~g:new_game
        ~rate_change:(Int.min (100 - new_game.happy_rate) 10))
  | Disable_Mandatory ->
      Ok (update_happy_rate ~g:new_game
        ~rate_change:(Int.min (100 - new_game.happy_rate) 10))
  | Increase_Occupancy -> Ok (update_happy_rate ~g:new_game
        ~rate_change:(Int.max (new_game.happy_rate - 10) 0))
  )
  )

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
  let robbery_risk = 0 in
  if
    List.exists game.implemented_policies ~f:(fun policy ->
        Policy.equal policy Policy.Disable_Mandatory)
  then robbery_risk + 1
  else robbery_risk

let get_fire_risk game =
  let fire_risk = 0 in
  if
    List.exists game.implemented_policies ~f:(fun policy ->
        Policy.equal policy Policy.Disable_Mandatory)
  then fire_risk + 1
  else fire_risk

let get_protest_risk game =
  let protest_risk = 0 in
  if
    List.exists game.implemented_policies ~f:(fun policy ->
        Policy.equal policy Policy.Clean_Energy)
  then protest_risk + 1
  else protest_risk

let implement_policy game policy =
  if
    List.exists game.implemented_policies ~f:(fun item ->
        Policy.equal item policy)
  then Error "You have already implemented this policy!"
  else
    Ok
      {
        game with
        implemented_policies = List.append game.implemented_policies [ policy ];
      }

let remove_policy game policy =
  if
    List.exists game.implemented_policies ~f:(fun item ->
        Policy.equal item policy)
  then
    Ok
      {
        game with
        implemented_policies =
          List.filter game.implemented_policies ~f:(fun item ->
              not (Policy.equal item policy));
      }
  else Error "You cannot remove a policy you haven't implemented"

let daily_events game =
  (* CR: Might want to make the possible event for that day chosen randomly from the list instead *)
  let robbery_risk = get_robbery_risk game in
  let fire_risk = get_fire_risk game in
  let protest_risk = get_protest_risk game in
  if robbery_risk * Random.int 100 > 95 then Some Event.Robbery
  else if fire_risk * Random.int 100 > 95 then Some Event.Fire
  else if protest_risk * Random.int 100 > 95 then Some Event.Protest
  else None

let get_feedback_categories (g : t) : Public_feedback.feedback_category list =
  let get_count b = Map.find g.building_counts b |> Option.value ~default:0 in
  let categories = ref [] in

  (* Check policies *)
  if
    List.exists g.implemented_policies
      ~f:(Policy.equal Policy.Disable_Mandatory)
  then categories := Public_feedback.Defund_mandatory :: !categories;

  if List.exists g.implemented_policies ~f:(Policy.equal Policy.Clean_Energy)
  then categories := Clean_power_pos :: !categories;

  (* Check tax *)
  if Float.(g.tax_rate > 40.0) then categories := High_tax :: !categories;

  (* Greenspace *)
  let greenspace = get_count Greenspace in
  if greenspace >= 5 then categories := Greenspace_pos :: !categories
  else categories := Greenspace_neg :: !categories;

  (* Grocery check *)
  if get_count Grocery = 0 then categories := No_grocery :: !categories;

  (* Business ratio *)
  let business = get_count Grocery + get_count Retail in
  let housing = get_count House + get_count Apartment in
  let ratio = Float.of_int business /. Float.of_int (housing + 1) in
  if Float.(ratio >. 1.2) then categories := High_business_ratio :: !categories
  else if Float.(ratio <. 0.8) then
    categories := Low_business_ratio :: !categories;

  (* High occupancy (very dense city) *)
  if housing > 10 && g.population / housing > 10 then
    categories := High_occupancy :: !categories;

  !categories

(*write expect test*)

(* time passing *)
let start_day game =
  print_endline "possible event";
  match daily_events game with
  | Some Event.Robbery -> robbery_event game
  | Some Event.Fire -> fire_event game
  | Some Event.Protest -> protest_event game
  | None -> game

let calculate_happiness (game : t) : int =
  let get_count b =
    Map.find game.building_counts b |> Option.value ~default:0
  in
  let greenspace = get_count Greenspace in
  let grocery = get_count Grocery in
  let retail = get_count Retail in
  let house = get_count House in
  let apartment = get_count Apartment in
  let school = get_count School in
  let university = get_count University in
  let housing = house + apartment in
  let business = grocery + retail in
  (* Greenspace score: maxed when there's 1 greenspace per housing unit *)
  let greenspace_score =
    Float.min 1.0 (Float.of_int greenspace /. Float.of_int (housing + 1))
  in
  (* Business-to-housing ratio: optimal around 0.5 *)
  let business_ratio = Float.of_int business /. Float.of_int (housing + 1) in
  let business_score =
    if Float.(business_ratio >= 0.4 && business_ratio <= 0.7) then 1.0
    else Float.max 0.0 (1.0 -. (Float.abs (business_ratio -. 0.55) *. 2.0))
  in
  (* Education score based on estimated students served *)
  let total_population = game.population in
  let students = total_population / 3 in
  let school_capacity = (school * 25) + (university * 100) in
  let education_score =
    Float.min 1.0 (Float.of_int school_capacity /. Float.of_int (students + 1))
  in
  (* Weighted average *)
  let weighted_score =
    (0.4 *. greenspace_score) +. (0.3 *. business_score)
    +. (0.3 *. education_score)
  in
  Float.to_int (weighted_score *. 100.0)

let tick game =
  print_endline "new day started";
  print_s [%message (game.current_day : int)];
  let updated_game = update_stats game in
  let new_day =
    {
      updated_game with
      current_day = updated_game.current_day + 1;
      happiness = calculate_happiness game;
    }
  in
  (* if new_day.happiness < 0 then Error "Game over! Happiness has reached 0"
  else if new_day.money < 0 then Error "Game over! Money has reached 0"
  else if new_day.population < 0 then
    Error "Game over! Population has reached 0"
  else  *)
  Ok new_day

let add_mandatory ~position game =
  let mandatory_buildings =
    [ Building.Electricity; Water; Police; Hospital; Fire ]
  in
  let next_mandatory =
    List.filter mandatory_buildings ~f:(fun item ->
        not (dup_mandatory game ~building:item))
  in
  if not (List.is_empty next_mandatory) then
    place_building game ~position ~building:(List.hd_exn next_mandatory)
  else Ok (end_tutorial game)
