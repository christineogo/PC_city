open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Js_of_ocaml
open Game_strategies_common_lib


module City_results = struct
 let default_value = 0  (*to maintain variable state for now, christine change this when backend is connected*)
let stats_items = [
  ("Population: ", default_value);
  ("Money: ", default_value);
  ("Happiness: ", default_value); 
  ("Day: ", default_value)
]

(*switch this list with the list in the backend *)
let opinion_messages = [
  "The power is out again...";
  "The hospitals are so fugazi(bad), I hope no one gets sick!";
  "Who's reaching my illegal function! There's no 12(police) to stop it!";
  "Bro I love the new education policy... Everyone is so locked in (focused)!";
  "These high taxes have me feeling a certain type of way (upset). Might leave soon...idk";
]


let component : Node.t Bonsai.Computation.t =
  Bonsai.const (

   Node.div ~attrs:[ Attr.class_ "sidebar" ] [
  (*City stats*)
    Node.div ~attrs:[Attr.class_ "section-box"]
    [
      Node.h3 ~attrs:[Attr.class_ "section-title"] [Node.text "City Stats"];
      Node.div ~attrs:[Attr.class_ "city-stats"]
      (List.map stats_items ~f:(fun (label, value)-> 
        Node.div ~attrs: [Attr.class_ "stats-item"][
          Node.span ~attrs: [Attr.class_ "stats-label"] [Node.text label]; 
          Node.span ~attrs: [Attr.class_ "legend-label"] [Node.text (string_of_int value)]
        ]))
    ]; 

    (*Public Opinion*)
    Node.div ~attrs: [Attr.class_ "section-box"]
    [
      Node.h3 ~attrs:[Attr.class_ "section-title"] [Node.text "Public Opinion"]; 
      Node.div ~attrs: [Attr.class_ "public-opinion"] 
      (List.map opinion_messages ~f:(fun(message)-> 
        Node.div ~attrs: [Attr.class_ "public-item"] [
          Node.span ~attrs: [Attr.class_ "public-label"] [Node.text message]
        ]
        ))
      ]
    ] ; 

  ) 

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

  let%sub title = Bonsai.const (Node.h1 ~attrs:[Attr.class_ "title"] [Node.text "PC City"]) in
  let%sub grid = Grid.component ~game ~set_game ~selected_cell ~set_selected_cell in 
  let%sub right_sidebar = City_results.component in 


  let%arr title = title
  and grid = grid and 
  right_sidebar = right_sidebar
  and set_game = set_game 
  in
  let new_game_on_click (_ev : Dom_html.mouseEvent Js.t) : unit Ui_effect.t =
    let new_game = Game.new_game () in
    Game.print_game new_game;
    set_game new_game
  in
  let button =
    Node.button
      ~attrs:[Attr.on_click new_game_on_click]
      [Node.text "Start Game"]
  in
  View.vbox [title; button; View.hbox [grid ;  right_sidebar ] ]
  

let () = Bonsai_web.Start.start component
