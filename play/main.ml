open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Js_of_ocaml
open Game_strategies_common_lib

module Info_modal = struct
  let component ~show ~on_close =
    let%arr show = show and on_close = on_close in
    if not show then Node.none
    else
      Node.div
        ~attrs:
          [ Attr.class_ "modal-overlay"; Attr.on_click (fun _ -> on_close ()) ]
        [
          Node.div
            ~attrs:
              [ Attr.class_ "modal"; Attr.on_click (fun _ -> Ui_effect.Ignore) ]
            [
              Node.h2
                [ Node.text "PC City : An Interactive City Simulator Game" ];
              Node.h3 [ Node.text "Overview" ];
              Node.p
                [
                  Node.text
                    "A city simulator, in which you are playing from birds-eye \
                     view to overlook a city grid. You are tasked with \
                     managing + building the city. You can add residences and \
                     businesses. You can also set tax rates to make money. The \
                     city will have a happiness score calculated based on the \
                     ratio of businesses to residences, as well as the tax \
                     rate. Your goal is to make a profitable city, while also \
                     ensuring that your city is happy.";
                ];
              Node.h3 [ Node.text "Gameplay" ];
              Node.p
                [
                  Node.text
                    "Your mayoral term will last 60 days. Here is an overview \
                     of the gameplay to ensure you are successful during your \
                     term.";
                ];
              Node.h4 [ Node.text "Overall Score:" ];
              Node.p
                [
                  Node.text
                    "Calculated based on the number of buildings you have \
                     placed down during your term as mayor. Try your best to \
                     expand your city, while maintaining your city stats.";
                ];
              Node.h4 [ Node.text "Buying buildings:" ];
              Node.p
                [
                  Node.text
                    "There are five mandatory buildings that you must place at \
                     the beginning of the game. The tutorial will instruct you \
                     to do so.";
                ];
              Node.p
                [
                  Node.text
                    "You can click on a grid block and then the city planner \
                     menu 'Buy' button to buy more buildings. Be sure to hover \
                     over each building type to learn more about the cost of \
                     the building and its effects.";
                ];
              Node.h4 [ Node.text "Making Money:" ];
              Node.p
                [
                  Node.text
                    "You can make money by placing down buildings that will \
                     bring in money. Hover over each building type in the city \
                     planner to learn more.";
                ];
              Node.p
                [
                  Node.text
                    "You can also make money by taxing your citizens. Be sure \
                     to monitor your tax rate and public opinion to make sure \
                     your taxes are not too high!";
                ];
              Node.h4 [ Node.text "Public Opinion:" ];
              Node.p
                [
                  Node.text
                    "Your public opinion tab is based entirely on your game \
                     state! You can monitor the public opinion to inform your \
                     decisions and find out what will make your people happy.";
                ];
              Node.h4 [ Node.text "Unpredictable Behaviors:" ];
              Node.p
                [
                  Node.text
                    "There is a chance that natural disasters can occur and \
                     reduce your population. This can depend on the policies \
                     you have enacted. Clean energy might be very popular with \
                     your city, but could also be a policy that will cause \
                     protest. Defunding mandatory services could make your \
                     city vulnerable to fires and pandemics. Be sure to hover \
                     over a policy and learn more about it before you enact \
                     them.";
                ];
              Node.button
                ~attrs:
                  [
                    Attr.class_ "modal-close";
                    Attr.on_click (fun _ -> on_close ());
                  ]
                [ Node.text "Close" ];
            ];
        ]
end

let component =
  let%sub game, set_game =
    Bonsai.state
      (module struct
        type t = Game.t [@@deriving sexp, equal]
      end)
      ~default_model:(Game.new_game ())
  in
  let%sub selected_cell, set_selected_cell =
    Bonsai.state_opt
      (module struct
        type t = int * int [@@deriving sexp, equal]
      end)
  in
  let%sub error_message, set_error_message =
    Bonsai.state_opt
      (module struct
        type t = string [@@deriving sexp, equal]
      end)
  in
  let%sub disaster_message, set_disaster_message =
    Bonsai.state_opt
      (module struct
        type t = string [@@deriving sexp, equal]
      end)
  in
  let%sub show_info_modal, set_show_info_modal =
    Bonsai.state (module Bool) ~default_model:false
  in

  let%sub title =
    let%arr set_show_info_modal = set_show_info_modal in
    Node.div
      ~attrs:[ Attr.class_ "title-container" ]
      [
        Node.h1 ~attrs:[ Attr.class_ "title" ] [ Node.text "PC City" ];
        Node.button
          ~attrs:
            [
              Attr.class_ "info-button";
              Attr.on_click (fun _ -> set_show_info_modal true);
            ]
          [ Node.text "ℹ️" ];
      ]
  in

  let%sub tutorial_message =
    let%arr game = game in
    let message =
      match game.game_stage with
      | Stage.Tutorial ->
          if Game.all_mandatory_placed game then
            "Great! Now select a block, then click a building's Buy button to \
             place it."
          else
            "Click on 5 different blocks to place down your mandatory \
             buildings."
      | _ -> "Overall Score: " ^ string_of_int game.score
    in
    Node.h3 ~attrs:[ Attr.class_ "tutorial-message" ] [ Node.text message ]
  in

  let%sub grid =
    Grid.component ~game ~set_game ~selected_cell ~set_selected_cell
      ~set_error_message
  in
  let%sub right_sidebar = City_result.component ~game in
  let%sub left_sidebar =
    City_planner.component ~game ~set_game ~selected_cell ~set_error_message
  in
  let%sub error_modal =
    Error_modal.component ~error_message ~set_error_message
  in
  let%sub disaster_modal =
    Disaster_modal.component ~disaster_message ~set_disaster_message
  in
  let%sub end_screen = Endscreen.component ~game ~on_restart in
  let%sub info_modal =
    Info_modal.component ~show:show_info_modal
      ~on_close:(Value.map set_show_info_modal ~f:(fun f -> fun () -> f false))
  in

  let%sub tick_handler =
    let%arr game = game
    and set_game = set_game
    and set_disaster_message = set_disaster_message in

    match game.game_stage with
    | Stage.Tutorial -> Bonsai.Effect.Ignore
    | _ -> (
        match Game.tick game with
        | Error msg ->
            let game_over_game = Game.game_over game in
            let%bind.Ui_effect () = set_game game_over_game in
            Bonsai.Effect.Ignore
        | Ok day ->
            let (new_game, _burned_positions), disaster = Game.start_day day in
            let%bind.Ui_effect () = set_game new_game in
            set_disaster_message disaster)
  in

  let%sub _ =
    let%arr game = game and set_game = set_game in
    match game.game_stage with
    | Stage.Tutorial when Game.all_mandatory_placed game ->
        set_game (Game.end_tutorial game)
    | _ -> Bonsai.Effect.Ignore
  in

  let%sub () =
    Bonsai.Clock.every ~trigger_on_activate:true
      ~when_to_start_next_effect:`Every_multiple_of_period_non_blocking
      (Time_ns.Span.of_sec 10.0) tick_handler
  in

  let%sub button =
    let%arr game = game and set_game = set_game in
    let label =
      match game.game_stage with
      | Stage.Tutorial -> "Start Game"
      | _ -> "Restart Game"
    in
    let new_game_on_click (_ev : Dom_html.mouseEvent Js.t) : unit Ui_effect.t =
      let new_game = Game.new_game () in
      Game.print_game new_game;
      set_game new_game
    in
    Node.div
      ~attrs:
        [
          Attr.create "style"
            "display: flex; justify-content: center; margin: 1rem 0;";
        ]
      [
        Node.button
          ~attrs:[ Attr.class_ "button"; Attr.on_click new_game_on_click ]
          [ Node.text label ];
      ]
  in

  let%arr title = title
  and tutorial_message = tutorial_message
  and grid = grid
  and right_sidebar = right_sidebar
  and left_sidebar = left_sidebar
  and button = button
  and error_modal = error_modal
  and disaster_modal = disaster_modal
  and end_screen = end_screen
  and info_modal = info_modal in

  View.vbox
    [
      info_modal;
      Node.div
        ~attrs:
          [
            Attr.create "style"
              "display: flex; justify-content: center; width: 100%;";
          ]
        [ title ];
      error_modal;
      disaster_modal;
      end_screen;
      button;
      tutorial_message;
      Node.div
        ~attrs:
          [
            Attr.create "style"
              "display: flex; justify-content: center; width: 100%;";
          ]
        [ View.hbox [ left_sidebar; grid; right_sidebar ] ];
    ]

let () = Bonsai_web.Start.start component
