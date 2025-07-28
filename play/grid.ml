open! Core 
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Game_strategies_common_lib

let grid_size = 20

let component ~game ~set_game ~selected_cell ~set_selected_cell= 
  (* let%sub selected_cell, set_selected_cell =
    Bonsai.state_opt
      (module struct
        type t = int * int [@@deriving sexp, equal]
      end)
  in *)

  let%arr selected_cell = selected_cell
  and set_selected_cell = set_selected_cell
  and game = game
  and set_game = set_game
  in

  let on_click (row, col) =
    let position = Position.create ~row ~col in
    (* set_selected_cell (Some (row, col)) *)
    let%bind.Ui_effect () = set_selected_cell (Some (row, col)) in
    let new_game = Game.add_mandatory ~position game in
    match game.game_stage with
    |Stage.Tutorial -> print_s[%message (new_game : Game.t)]; set_game new_game
    |_ -> set_game game
  in

  let cell ~row ~col =
    let is_selected = Option.equal [%equal: int * int] selected_cell (Some (row, col)) in
    let classes =
      if is_selected then [ "grid-cell"; "selected" ] else [ "grid-cell" ]
    in
    Node.td
      ~attrs:[
        Attr.classes classes;
        Attr.on_click (fun _ -> on_click (row, col))
      ]
      []
  in

  let row ~row_index =
    Node.tr
      ~attrs:[]
      (List.init grid_size ~f:(fun col_index ->
         cell ~row:row_index ~col:col_index))
  in

  Node.table
    ~attrs:[Attr.class_ "grid-table"]
    (List.init grid_size ~f:(fun row_index -> row ~row_index))

