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
    let open Public_feedback in
    let categories = Game.get_feedback_categories game in
    match
      List.find_map categories ~f:(fun cat ->
          List.random_element (get_feedback_for_category cat))
    with
    | Some msg -> set_opinion_messages (msg :: opinion_messages)
    | None -> Effect.Ignore
  in

  (* Automatically run inject_opinion_message each tick *)
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
          Node.div
            ~attrs:[ Attr.class_ "city-stats" ]
            (List.concat
               [
                 List.map stats_items ~f:(fun (label, value) ->
                     Node.div
                       ~attrs:[ Attr.class_ "stats-item" ]
                       [
                         Node.span
                           ~attrs:[ Attr.class_ "stats-label" ]
                           [ Node.text label ];
                         Node.span
                           ~attrs:[ Attr.class_ "stats-label" ]
                           [ Node.text (string_of_int value) ];
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
                       [ Node.text message ];
                   ]));
        ];
    ]
