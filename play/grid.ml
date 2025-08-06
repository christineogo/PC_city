open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Game_strategies_common_lib

let grid_size = 15

let component ~game ~set_game ~selected_cell ~set_selected_cell
    ~set_error_message ~burned_positions =
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
  and set_error_message = set_error_message
  and burned_positions = burned_positions in

  let on_click (row, col) =
    let position = Position.create ~row ~col in
    (* set_selected_cell (Some (row, col)) *)
    let%bind.Ui_effect () = set_selected_cell (Some (row, col)) in
    let new_game = Game.add_mandatory ~position game in
    match game.game_stage with
    | Stage.Tutorial -> (
        (* print_s[%message (new_game : Game.t)]; set_game new_game *)
        match new_game with
        | Ok ok_game ->
            print_s [%message (ok_game : Game.t)];
            set_game ok_game
        | Error message ->
            print_endline message;
            set_error_message (Some message))
    | _ -> set_game game
  in

  let cell ~row ~col =
    let is_selected =
      Option.equal [%equal: int * int] selected_cell (Some (row, col))
    in
    let classes =
      if is_selected then [ "grid-cell"; "selected" ] else [ "grid-cell" ]
    in

    let position = Position.create ~row ~col in
    let building_opt = Game.get_building game ~position in

    let color =
      match building_opt with
      | Some building -> Building.get_color building
      (* | None -> "#D3D3D3" *)
       |None -> (match game.flood_queue with 
      |Some flood_queue -> if List.mem flood_queue position ~equal:Position.equal then "#00008B" else "#D3D3D3"
      |None ->"#D3D3D3")
    in

    let fire_icon =
      match burned_positions with
      | Some ps when List.exists ps ~f:(Position.equal position) ->
          Node.img
            ~attrs:[ Attr.src "assets/fire.png"; Attr.class_ "fire-icon" ]
            ()
      | _ -> Node.none
    in

    Node.td
      ~attrs:
        [
          Attr.classes classes;
          Attr.create "style" ("background: " ^ color);
          Attr.on_click (fun _ -> on_click (row, col));
        ]
      [ fire_icon ]
  in

  let row ~row_index =
    Node.tr ~attrs:[]
      (List.init grid_size ~f:(fun col_index ->
           cell ~row:row_index ~col:col_index))
  in

  Node.table
    ~attrs:[ Attr.class_ "grid-table" ]
    (List.init grid_size ~f:(fun row_index -> row ~row_index))
