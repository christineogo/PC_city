open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Game_strategies_common_lib

let component ~_is_game_over ~on_restart ~(game : Game.t Value.t)=
  let%arr 
  (* is_game_over = is_game_over and  *)
  on_restart = on_restart and 
  game = game in
  match game.game_stage with
  | Stage.Tutorial | Game_continues -> Node.none
  | Win ->
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
              Node.p
                [
                  Node.text
                    "Congratulations! \
                     you have reached the end of your term! Your final score is:";
                ];
                Node.h3
                [
                  Node.text
                    (Int.to_string game.score);
                ];
              Node.button
                ~attrs:
                  [
                    Attr.class_ "modal-close";
                    Attr.on_click (fun _ -> on_restart ());
                  ]
                [ Node.text "Play Again" ];
            ];
        ]
  |Game_over ->
    Node.div
        ~attrs:
          [
            Attr.class_ "modal-overlay"; Attr.on_click (fun _ -> Effect.Ignore);
          ]
        [
          Node.div
            ~attrs:[ Attr.class_ "modal" ]
            [
              Node.h2 [ Node.text "You Lost!" ];
              Node.p
                [
                  Node.text
                    "You lost! \
                     Hopefully PC city gets a better mayor next time!";
                ];
                Node.h3
                [
                  Node.text
                    (Int.to_string game.score);
                ];
              Node.button
                ~attrs:
                  [
                    Attr.class_ "modal-close";
                    Attr.on_click (fun _ -> on_restart ());
                  ]
                [ Node.text "Play Again" ];
            ];
        ]
