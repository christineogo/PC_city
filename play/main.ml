open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Js_of_ocaml
open Game_strategies_common_lib


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

  let%sub _error_message, set_error_message =
    Bonsai.state_opt
      (module struct
        type t = string [@@deriving sexp, equal]
      end)
  in

  let%sub title = Bonsai.const (Node.h1 ~attrs:[Attr.class_ "title"] [Node.text "PC City"]) in
  let%sub grid = Grid.component ~game ~set_game ~selected_cell ~set_selected_cell ~set_error_message in 
  let%sub right_sidebar = City_result.component in 
  let%sub left_sidebar = City_planner.component ~game ~set_game ~selected_cell ~set_error_message in 


  let%sub tick_handler = 
    let%arr game = game and
    set_game = set_game in (set_game (Result.ok_or_failwith (Game.tick game))) 
  in
  let%sub _ =
    let%arr game = game in
    Game.tick game
  in
  let%sub () =
    Bonsai.Clock.every
      ~trigger_on_activate: true
      ~when_to_start_next_effect: `Every_multiple_of_period_non_blocking
      (Time_ns.Span.of_sec 10.0)
      tick_handler

 in


  let%arr title = title
  and grid = grid and 
  right_sidebar = right_sidebar
  and left_sidebar = left_sidebar and set_game = set_game 
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
  View.vbox [title; button; View.hbox [left_sidebar; grid ;  right_sidebar ] ]
  

let () = Bonsai_web.Start.start component
