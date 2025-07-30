open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Game_strategies_common_lib

(*switch this list with the list in the backend *)
let opinion_messages =
  [
    "The power is out again...";
    "The hospitals are so fugazi(bad), I hope no one gets sick!";
    "Who's reaching my illegal function! There's no 12(police) to stop it!";
    "Bro I love the new education policy... Everyone is so locked in (focused)!";
    "These high taxes have me feeling a certain type of way (upset). Might \
     leave soon...idk";
  ]

let component ~(game : Game.t Value.t) =
  let%arr game = game in
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
      (*City stats*)
      Node.div
        ~attrs:[ Attr.class_ "section-box" ]
        [
          Node.h3
            ~attrs:[ Attr.class_ "section-title" ]
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
      (*Public Opinion*)
      Node.div
        ~attrs:[ Attr.class_ "section-box" ]
        [
          Node.h3
            ~attrs:[ Attr.class_ "section-title" ]
            [ Node.text "Public Opinion" ];
          Node.div
            ~attrs:[ Attr.class_ "public-opinion" ]
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
