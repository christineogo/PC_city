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

  let%sub title = Bonsai.const (Node.text "PC City") in

  (* Pass game and set_game into Grid.component *)
  let%sub grid = Grid.component ~game ~set_game in

  let%arr title = title
  and grid = grid
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
  View.vbox [title; button; grid]

let () = Bonsai_web.Start.start component
