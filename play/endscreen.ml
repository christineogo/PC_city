open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open Game_strategies_common_lib

let component ~(game : Game.t Value.t)
    ~(set_game : (Game.t -> unit Effect.t) Value.t)
    ~(message : string option Value.t) ~(on_restart : unit Effect.t Value.t) :
    Vdom.Node.t Computation.t =
  let%arr game = game
  and _set_game = set_game
  and message_option = message
  and on_restart = on_restart in

  match game.game_stage with
  | Stage.Tutorial | Stage.Game_continues -> Node.none
  | Stage.Win ->
      Node.div
        ~attrs:
          [
            Attr.class_ "modal-overlay"; Attr.on_click (fun _ -> Effect.Ignore);
          ]
        [
          Node.div
            ~attrs:[ Attr.class_ "modal" ]
            [
              Node.h2 [ Node.text "You won!" ];
              (* optional custom message *)
              (match message_option with
              | Some msg -> Node.p [ Node.text msg ]
              | None -> Node.none);
              Node.h3 [ Node.text ("Score: " ^ Int.to_string game.score) ];
              Node.button
                ~attrs:
                  [
                    Attr.class_ "modal-close";
                    Attr.on_click (fun _ -> on_restart);
                  ]
                [ Node.text "Play Again" ];
            ];
        ]
  | Stage.Game_over ->
      Node.div
        ~attrs:
          [
            Attr.class_ "modal-overlay"; Attr.on_click (fun _ -> Effect.Ignore);
          ]
        [
          Node.div
            ~attrs:[ Attr.class_ "modal" ]
            [
              Node.h2 [ Node.text "Game Over" ];
              (match message_option with
              | Some msg -> Node.p [ Node.text msg ]
              | None -> Node.none);
              Node.h3 [ Node.text ("Score: " ^ Int.to_string game.score) ];
              Node.button
                ~attrs:
                  [
                    Attr.class_ "modal-close";
                    Attr.on_click (fun _ -> on_restart);
                  ]
                [ Node.text "Try Again" ];
            ];
        ]
