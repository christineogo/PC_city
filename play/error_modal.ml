open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Game_strategies_common_lib

let component ~error_message ~set_error_message =
  let%arr error_message = error_message
  and set_error_message = set_error_message in
  match error_message with
  | None -> Node.none
  | Some msg ->
      Node.div
        ~attrs:
          [
            Attr.class_ "modal-overlay";
            Attr.on_click (fun _ -> set_error_message None);
          ]
        [
          Node.div
            ~attrs:[ Attr.class_ "modal" ]
            [
              Node.h2 [ Node.text "Error" ];
              Node.p [ Node.text msg ];
              Node.button
                ~attrs:[ Attr.on_click (fun _ -> set_error_message None) ]
                [ Node.text "Close" ];
            ];
        ]
