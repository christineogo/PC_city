open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Game_strategies_common_lib

let component ~disaster_message ~set_disaster_message ~set_burned_positions ~burned_positions ~game ~(set_game : (Game.t -> unit Bonsai.Effect.t) Value.t)=
  let%arr disaster_message = disaster_message
  and set_disaster_message = set_disaster_message 
  and set_burned_positions = set_burned_positions
  and game = game
  and set_game = set_game
  and burned_positions = burned_positions
in
  let on_click = 
      match burned_positions with 
  |None -> set_game game
  |Some positions -> let%bind.Ui_effect () = set_burned_positions None in set_game (Game.burn_buildings positions game)
in
  match disaster_message with
  | None -> Node.none
  | Some msg ->
      Node.div
        ~attrs:
          [
            Attr.class_ "modal-overlay";
            Attr.on_click (fun _ -> let%bind.Ui_effect () = on_click in set_disaster_message None);
          ]
        [
          Node.div
            ~attrs:[ Attr.class_ "modal" ]
            [
              Node.h2 [ Node.text "Disaster!" ];
              Node.p [ Node.text msg ];
              Node.button
                ~attrs:
                  [
                    Attr.class_ "modal-close";
                    Attr.on_click (fun _ -> set_disaster_message None);
                  ]
                [ Node.text "Close" ];
            ];
        ]
    
