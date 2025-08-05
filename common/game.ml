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
}
[@@deriving sexp, equal]

let base_happiness = 15

let new_game () =
  {
    game_stage = Stage.Tutorial;
    board = Position.Map.empty;
    building_counts = Building.Map.empty;
    implemented_policies = [];
    population = 1;
    money = 2000;
    happiness = base_happiness;
    population_rate = 0;
    money_rate = 0;
    happy_rate = 0;
    current_day = 0;
    tax_rate = 0.0;
    score = 0;
    daily_cost = -50;
    small_cost = -100;
    medium_cost = -250;
    high_cost = -500;
    ultra_high_cost = -750;
  }

let mandatory_buildings =
  [ Building.Electricity; Water; Police; Hospital; Fire ]

let get_money_change game building =
  match building with
  | Building.Police -> game.daily_cost
  | Electricity -> game.daily_cost
  | Fire -> game.daily_cost
  | House -> 0
  | University -> game.daily_cost
  | School -> game.daily_cost
  | Grocery -> -game.small_cost
  | Retail -> -game.small_cost
  | Apartment -> 0
  | Greenspace -> 0
  | Water -> game.daily_cost
  | Hospital -> game.daily_cost

let building_cost game building =
  match building with
  | Building.Police -> 0
  | Electricity -> 0
  | Fire -> 0
  | House -> game.small_cost
  | University -> game.high_cost
  | School -> game.medium_cost
  | Grocery -> game.medium_cost
  | Retail -> game.medium_cost
  | Apartment -> game.high_cost
  | Greenspace -> game.daily_cost
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
    { new_game with money = game.money + building_cost game building }
  in
  update_money_rate ~g:building_cost_game
    ~rate_change:(get_money_change game building)

(* placing structures *)
let get_building t ~position = Map.find t.board position

let dup_mandatory t ~building =
  if not (List.exists mandatory_buildings ~f:(Building.equal building)) then
    false
  else
    match Map.find t.building_counts building with Some 1 -> true | _ -> false

let place_building t ~position ~building =
  if dup_mandatory t ~building then
    Error "You cannot place multiple mandatory buildings"
  else if Position.in_bounds position then
    if Map.mem t.board position then
      Error
        "There is already a building here. Try selecting another grid block."
    else
      let board = Map.set t.board ~key:position ~data:building in
      let building_counts =
        Map.update t.building_counts building ~f:(function
          | None -> 1
          | Some count -> count + 1)
      in
      let new_game = { t with board; building_counts } in
      Ok (update_stats_from_building ~game:new_game ~building)
  else Error "Position is out of bounds"

let tutorial_placement t ~position ~building =
  if not (List.exists mandatory_buildings ~f:(Building.equal building)) then
    Error
      "You can only place mandatory buildings in this part of the tutorial. \
       Select 5 different blocks to place your electricity, water, police, \
       hospital, and fire station. "
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

let all_mandatory_placed game =
  let next_mandatory =
    List.filter mandatory_buildings ~f:(fun item ->
        not (dup_mandatory game ~building:item))
  in
  List.is_empty next_mandatory

(* policies and effects *)

let disable_effect game =
  if all_mandatory_placed game then
    Ok
      {
        (update_happy_rate ~g:game
           ~rate_change:(Int.min (100 - game.happy_rate) 10))
        with
        money = game.money + game.ultra_high_cost;
        money_rate = game.money_rate + 250;
      }
  else Error "You must have all mandatory buildings placed before disabling!"

let increase_occupancy_effect game =
  if
    Map.mem game.building_counts Building.Apartment
    || Map.mem game.building_counts House
  then
    Ok
      {
        game with
        population = Float.to_int (Int.to_float game.population *. 1.2);
        happiness = max 0 (game.happiness - 10);
      }
  else Error "Place a house or apartment first to increase occupancy rate."

let enact_policy ~policy ~game =
  match List.mem game.implemented_policies policy ~equal:Policy.equal with
  | true -> Error "You have already implemented this policy"
  | false -> (
      let new_game =
        {
          game with
          implemented_policies =
            List.append game.implemented_policies [ policy ];
        }
      in
      match policy with
      | Policy.Education ->
          Ok
            {
              (update_happy_rate ~g:new_game
                 ~rate_change:(Int.min (100 - new_game.happy_rate) 10))
              with
              money = game.money + game.ultra_high_cost;
            }
      | Clean_Energy ->
          Ok
            {
              (update_happy_rate ~g:new_game
                 ~rate_change:(Int.min (100 - new_game.happy_rate) 10))
              with
              money = game.money + game.ultra_high_cost;
            }
      | Disable_Mandatory -> disable_effect new_game
      | Increase_Occupancy -> increase_occupancy_effect new_game)

let fire_event game =
  print_endline "A fire has hit your town!";
  let burnable_map =
    Map.filter game.board ~f:(fun building ->
        not (List.mem mandatory_buildings building ~equal:Building.equal))
  in
  match Map.is_empty burnable_map with
  | _ ->
      {
        game with
        happiness = max 0 (game.happiness - 10);
        money = Float.to_int (Int.to_float game.money *. 0.75);
      }
(* | false ->
    let burnable_locations = Map.to_alist burnable_map in
    let random_location, _ = List.random_element_exn burnable_locations in
    {(Result.ok_or_failwith (remove_building game ~position:random_location)) with
    happiness = max 0 (game.happiness - 10); 
    money = Float.to_int (Int.to_float game.money *. 0.75);} *)
(* game *)
(* {
    game with
    population = Float.to_int (Int.to_float game.population *. 0.85);
    money = Float.to_int (Int.to_float game.money *. 0.85);
    happiness = Int.max 0 game.happiness - 10;
  } *)

let protest_event game =
  print_endline
    "Your residents are protesting! Some people are not a fan of your clean \
     energy policy. They have decided to leave. Your population will \
     decrease. ";
  game
(* {
    game with
    population = game.population - 10;
    happiness = Int.max 0 game.happiness - 5;
  } *)

let robbery_event game =
  print_endline
    "Robberies have struck your town! Defunding mandatory services left PC \
     City citizens vunerable to such attacks. Your population will decrease. \
     They are leaving to find somewhere safer to live. ";
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

  (* Policy-based feedback *)
  if
    List.exists g.implemented_policies
      ~f:(Policy.equal Policy.Disable_Mandatory)
  then categories := Public_feedback.Defund_mandatory :: !categories;

  if List.exists g.implemented_policies ~f:(Policy.equal Policy.Clean_Energy)
  then categories := Clean_power_pos :: !categories;

  (* Greenspace feedback *)
  let greenspace = get_count Greenspace in
  print_s [%message (greenspace : int)];
  if greenspace >= 5 then categories := Greenspace_pos :: !categories
  else categories := Greenspace_neg :: !categories;

  (* Grocery store feedback *)
  if get_count Grocery = 0 then categories := No_grocery :: !categories;

  if get_count School = 0 then categories := No_schools :: !categories;

  (* Business ratio feedback *)
  let business = get_count Grocery + get_count Retail in
  let housing = get_count House + get_count Apartment in
  let ratio = Float.of_int business /. Float.of_int (housing + 1) in
  if Float.(ratio > 1.2) then categories := High_business_ratio :: !categories
  else if Float.(ratio < 0.8) then
    categories := Low_business_ratio :: !categories;

  (* High occupancy feedback *)
  if
    List.exists g.implemented_policies
      ~f:(Policy.equal Policy.Increase_Occupancy)
  then
    if housing > 0 && g.population / housing > 10 then
      categories := High_occupancy :: !categories;

  (* Tax feedback: assume tax_rate is a float in [0.0, 1.0] *)
  if Float.(g.tax_rate > 40.) then categories := High_tax :: !categories;
  print_s [%message (g.tax_rate : float)];

  print_s [%message (!categories : Public_feedback.feedback_category list)];
  !categories

(* time passing *)
let start_day game =
  print_endline "possible event";
  match daily_events game with
  | Some Event.Robbery ->
      ( robbery_event game,
        Some
          "Robberies have struck your town! Defunding mandatory services left \
           PC City citizens vunerable to such attacks. You have lost some \
           money as well. " )
  | Some Event.Fire ->
      ( fire_event game,
        Some
          "A fire has struck your town. Unfortunately, your population will \
           decrease" )
  | Some Event.Protest ->
      ( protest_event game,
        Some
          "Your residents are protesting! Some people are not a fan of your \
           clean energy policy. They have decided to leave. Your population \
           will decrease. " )
  | None -> (game, None)

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
  let addition_factor = ref (Int.to_float base_happiness) in
  if business > 5 || housing > 5 then addition_factor := 5.;

  (* Greenspace score: maxed when there's 1 greenspace per housing unit *)
  let greenspace_score =
    Float.min 1.0 (Float.of_int greenspace /. Float.of_int (housing + 1))
  in
  (* Business-to-housing ratio: optimal around 0.5 *)
  let business_ratio = Float.of_int business /. Float.of_int (housing + 1) in
  let business_score =
    if Float.(business_ratio >= 0.4 && business_ratio <= 0.7) then 1.0
    else 1.0 -. (Float.abs (business_ratio -. 0.55) *. 2.0)
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
  min
    (max 0
       (Float.to_int
          ((weighted_score *. 100.0) -. (0.3 *. game.tax_rate)
         +. !addition_factor)))
    100

let calculate_score game =
  Map.fold game.building_counts ~init:0 ~f:(fun ~key:_ ~data:count acc ->
      acc + count)

let increase_costs_by_score (g : t) : t =
  let multiplier = g.score / 10 in
  {
    g with
    daily_cost = -50 - (5 * multiplier);
    small_cost = -100 - (10 * multiplier);
    medium_cost = -250 - (25 * multiplier);
    high_cost = -500 - (50 * multiplier);
    ultra_high_cost = -750 - (75 * multiplier);
  }

let tick game =
  (* let should_update_happiness =
  Map.length game in *)
  print_endline "new day started";
  print_s [%message (game.current_day : int)];
  let updated_game = update_stats game in
  let new_day =
    {
      updated_game with
      current_day = updated_game.current_day + 1;
      happiness = calculate_happiness updated_game;
      score = calculate_score updated_game;
    }
  in
  let scaled_game = increase_costs_by_score new_day in
  (* if new_day.happiness < 0 then Error "Game over! Happiness has reached 0"
  else  *)
  if new_day.money < 0 then
    Error
      "Game over! Money has reached 0. It is your job to maintain your \
       population, money, and happiness of PC City. We hope the next mayor is \
       better..."
  else if new_day.population < 0 then
    Error
      "Game over! Population has reached 0. It is your job to maintain your \
       population, money, and happiness of PC City. We hope the next mayor is \
       better..."
  else if new_day.current_day >= 60 then
    Error
      "Your term has ended. Congrats on making it (surviving) through all 60 \
       days. Do you think you could do better next time?"
  else Ok scaled_game

let add_mandatory ~position game =
  let next_mandatory =
    List.filter mandatory_buildings ~f:(fun item ->
        not (dup_mandatory game ~building:item))
  in
  if not (List.is_empty next_mandatory) then
    place_building game ~position ~building:(List.hd_exn next_mandatory)
  else Ok (end_tutorial game)
