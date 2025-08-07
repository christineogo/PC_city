open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Game_strategies_common_lib

let component ~(game : Game.t Value.t) =
  let%sub opinion_messages, set_opinion_messages =
    Bonsai.state
      (module struct
        type t = string list [@@deriving sexp, equal]
      end)
      ~default_model:[]
  in

  let%sub inject_opinion_message =
    let%arr game = game
    and set_opinion_messages = set_opinion_messages
    and opinion_messages = opinion_messages in
    match game.game_stage with
    | Stage.Tutorial -> Effect.Ignore
    | _ -> (
        let open Public_feedback in
        let categories = Game.get_feedback_categories game in
        match List.random_element categories with
        | Some category -> (
            match List.random_element (get_feedback_for_category category) with
            | Some msg -> set_opinion_messages (msg :: opinion_messages)
            | None -> Effect.Ignore)
        | None -> Effect.Ignore)
  in

  let%sub () =
    Bonsai.Clock.every ~trigger_on_activate:true
      ~when_to_start_next_effect:`Every_multiple_of_period_non_blocking
      (Time_ns.Span.of_sec 10.0) inject_opinion_message
  in

  let%arr game = game and opinion_messages = opinion_messages in
  let stats_items =
    [
      ("Population: ", game.population);
      ("Money: ", game.money);
      ("Day: ", game.current_day);
    ]
  in

  let happiness_bar ~value =
    Node.div
      ~attrs:[ Attr.class_ "happiness-bar-container" ]
      [
        Node.div
          ~attrs:
            [
              Attr.class_ "happiness-bar-fill";
              Attr.create "style" ("width:" ^ Int.to_string value ^ "%");
            ]
          [];
      ]
  in

  Node.div
    ~attrs:[ Attr.class_ "sidebar" ]
    [
      (* City Stats *)
      Node.div
        ~attrs:[ Attr.class_ "section-box" ]
        [
          Node.h3
            ~attrs:[ Attr.class_ "sidebar-title" ]
            [ Node.text "City Stats" ];
          Node.h3
            ~attrs:[ Attr.class_ "tips" ]
            [
              Node.text
                "Make sure to monitor your people! If any of these get too \
                 low, your city will fail";
            ];
          Node.div
            ~attrs:[ Attr.class_ "city-stats" ]
            (List.concat
               [
                 List.map stats_items ~f:(fun (label, value) ->
                     let value_attrs =
                       match label with
                       | "Money: " when value < 1000 ->
                           [
                             Attr.class_ "stats-label";
                             Attr.create "style" "color: red;";
                           ]
                       | "Day: " ->
                           [
                             Attr.class_ "stats-label";
                             Attr.title ("Day: " ^ string_of_int value ^ "/30");
                           ]
                       | _ -> [ Attr.class_ "stats-label" ]
                     in
                     Node.div
                       ~attrs:[ Attr.class_ "stats-item" ]
                       [
                         Node.span
                           ~attrs:[ Attr.class_ "stats-label" ]
                           [ Node.text label ];
                         Node.span ~attrs:value_attrs
                           [
                             Node.text
                               (match label with
                               | "Day: " -> string_of_int value ^ "/30"
                               | _ -> string_of_int value);
                           ];
                       ]);
                 [
                   Node.span
                     ~attrs:[ Attr.class_ "stats-label" ]
                     [
                       Node.text "Happiness";
                       happiness_bar ~value:game.happiness;
                     ];
                 ];
               ]);
        ];
      (* Public Opinion Log *)
      Node.div
        ~attrs:[ Attr.class_ "section-box" ]
        [
          Node.h3
            ~attrs:[ Attr.class_ "sidebar-title" ]
            [ Node.text "Public Opinion" ];
          Node.div
            ~attrs:
              [
                Attr.class_ "public-opinion";
                Attr.create "style" "overflow-y: scroll; max-height: 200px;";
              ]
            (List.map opinion_messages ~f:(fun message ->
                 Node.div
                   ~attrs:[ Attr.class_ "public-item" ]
                   [
                     Node.span
                       ~attrs:[ Attr.class_ "public-label" ]
                       [ Node.text message; Node.br (); Node.br () ];
                   ]));
        ];
    ]
