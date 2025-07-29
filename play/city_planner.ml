open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Game_strategies_common_lib


let policies =
  [ "Clean Energy"
  ; "Improve Education"
  ; "Increase Housing Occupancy"
  ; "Defund Mandatory Services"
  ]

let mandatory_services =
  [ ("#f4d35e", "Electricity", "-50/day");
    ("#4a90e2", "Water", "-50/day");
    ("#22303c", "Police", "-75/day");
    ("#ffffff", "Hospital", "-75/day");
    ("#e63946", "Fire Station", "-75/day")
  ]

let component ~(game: Game.t Value.t) ~(set_game: (Game.t -> unit Bonsai.Effect.t) Value.t) ~(selected_cell:(int * int) option Value.t) ~set_error_message=

let%sub tax_rate, set_tax_rate =
  Bonsai.state (module Float) ~default_model:0.0
in


  let%arr selected_cell = selected_cell
  and game = game
  and set_game = set_game
  and set_error_message = set_error_message
  and tax_rate = tax_rate
  and set_tax_rate = set_tax_rate
  in



  let get_building_counts building_type =
     match Map.find game.building_counts (Building.of_string building_type) with 
     | Some count -> count 
     | None -> 0 
  in 
  let planner_items =
  [
    ("#888888", get_building_counts "University", "University");
    ("#f4a261", get_building_counts "School",  "School");
    ("#a8d5a2", get_building_counts "Grocery", "Grocery");
    ("#e76f51", get_building_counts "Retail", "Retail");
    ("#b38728", get_building_counts "House", "House");
    ("#8c5a2f", get_building_counts "Apartment", "Apartment");
    ("#2a5d00", get_building_counts "Greenspace", "Greenspace");
  ] in 


  let on_click  ~building=
  match selected_cell with
    |Some pos ->
      (let row, col = pos in
    let new_position = Position.create ~row ~col in
    match game.game_stage with
    |Stage.Tutorial -> (let new_game = Game.tutorial_placement game ~position:new_position ~building in
    match new_game with
    | Ok ok_game -> print_s[%message (ok_game : Game.t)];
    (*Grid.change_color ~building_type: building ~row:row ~col:col ; *)
    set_game (ok_game)
    | Error message -> print_endline(message); set_error_message (Some message)

    (* if Result.is_ok new_game then (print_s[%message (Result.ok_or_failwith new_game : Game.t)];
    set_game (Result.ok_or_failwith new_game)) else (print_s[%message (Result.ok_or_failwith new_game : Game.t)];
    set_game (Result.ok_or_failwith new_game)) *)
    
    ) 
    |_ -> (let new_game = Game.place_building game ~position:new_position ~building in
    match new_game with
    | Ok ok_game -> print_s[%message (ok_game : Game.t)];
    (*Grid.change_color ~building_type:building ~row:row ~col:col ; *) 
    set_game (ok_game)
    | Error message -> print_endline(message); set_error_message (Some message))
      )


    (* if Result.is_ok new_game then print_s[%message (Result.ok_or_failwith new_game : Game.t)];
    set_game (Result.ok_or_failwith new_game)) *)
    |None -> set_game game

  in

    Node.div ~attrs:[ Attr.class_ "sidebar" ] [

      (* Header *)
      Node.h2 ~attrs:[ Attr.class_ "sidebar-title" ] [ Node.text "City Planner" ];

      (* Legend/Buy list *)
      Node.div ~attrs:[ Attr.class_ "legend" ]
        (List.map planner_items ~f:(fun (color, count, label) ->
           Node.div ~attrs:[ Attr.class_ "legend-item" ] [
             Node.span
               ~attrs:[ Attr.class_ "legend-label"; Attr.create "style" ("display:inline-block;width:16px;height:16px;background:" ^ color ^ ";margin-right:8px;vertical-align:middle;") ]
               [ Node.text "" ];
              Node.span ~attrs:[ Attr.class_ "legend-label" ] [ Node.text  (string_of_int count)];
             Node.span ~attrs:[ Attr.class_ "legend-label" ] [ Node.text label ];
             Node.button
               ~attrs:[ Attr.class_ "legend-buy"; Attr.on_click (fun _ -> on_click ~building:(Building.of_string label)) ]
               [ Node.text "Buy" ];
           ]
         ));

      (* Policies box *)
      Node.div ~attrs:[ Attr.class_ "section-box" ] [
        Node.h3 ~attrs:[ Attr.class_ "section-title" ] [ Node.text "Policies" ];
        Node.div ~attrs:[ Attr.class_ "policies" ]
          (List.map policies ~f:(fun p ->
             Node.div ~attrs:[ Attr.class_ "policy-item" ] [
               Node.span ~attrs:[ Attr.class_ "policy-label" ] [ Node.text p ];
               Node.button
                 ~attrs:[ Attr.class_ "policy-enact"; Attr.on_click (fun _ -> Bonsai_web.Effect.Ignore) ]
                 [ Node.text "Enact" ];
             ]))
      ];

      (* Tax slider *)
      Node.div ~attrs:[ Attr.class_ "section-box" ] [
        Node.h3 ~attrs:[ Attr.class_ "section-title" ] [ Node.text (sprintf "Tax: %.0f%%" tax_rate) ];
        Node.div ~attrs:[ Attr.class_ "slider-container" ] [
          Node.input
            ~attrs:[
              Attr.type_ "range";
              Attr.min 0.0; Attr.max 100.0; Attr.value "0";
              Attr.class_ "tax-slider";
              Attr.on_input (fun ev _->  
      let open Js_of_ocaml in
let target = Js.Opt.get ev##.target (fun () -> assert false) in
let input = Js.Opt.get (Dom_html.CoerceTo.input target) (fun () -> assert false) in
let value_str = Js.to_string input##.value in              
      (* let value_str = Js_of_ocaml.Js.to_string ev##.target##.value in *)
      match Float.of_string_opt value_str with
      | Some new_rate -> let new_game = {game with tax_rate = new_rate} in
      print_s[%message (new_game: Game.t)];
      let%bind.Ui_effect () = set_game new_game 
    in set_tax_rate new_rate
      | None -> set_tax_rate tax_rate
    )
            ] ()
        ]
      ];

      (* Mandatory services *)
      Node.div ~attrs:[ Attr.class_ "section-box" ] [
        Node.h3 ~attrs:[ Attr.class_ "section-title" ] [ Node.text "Mandatory" ];
        Node.div ~attrs:[ Attr.class_ "mandatory" ]
          (List.map mandatory_services ~f:(fun (color, label, cost) ->
             Node.div ~attrs:[ Attr.class_ "mandatory-item" ] [
               Node.span
                 ~attrs:[ Attr.class_ "swatch"; Attr.create "style" ("display:inline-block;width:16px;height:16px;background:" ^ color ^ ";margin-right:8px;vertical-align:middle;") ]
                 [ Node.text "" ];
               Node.span ~attrs:[ Attr.class_ "mandatory-label" ] [ Node.text label ];
               Node.span ~attrs:[ Attr.class_ "mandatory-cost" ] [ Node.text cost ];
             ]))
      ];
    ]


