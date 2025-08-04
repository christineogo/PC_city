open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Game_strategies_common_lib

let component ~is_game_over ~on_restart =
  let%arr is_game_over = is_game_over and on_restart = on_restart in
  match is_game_over with
  | false -> Node.none
  | true ->
      Node.div
        ~attrs:
          [
            Attr.class_ "modal-overlay"; Attr.on_click (fun _ -> Effect.Ignore);
          ]
        [
          Node.div
            ~attrs:[ Attr.class_ "modal" ]
            [
              Node.h2 [ Node.text "Your city has failed!" ];
              Node.p
                [
                  Node.text
                    "Congratulations! \
                     you have reached the end of your term! Your final score is:";
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
