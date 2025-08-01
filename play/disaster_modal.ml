open! Core
open! Bonsai_web
open! Bonsai.Let_syntax
open! Virtual_dom.Vdom
open! Game_strategies_common_lib

let component ~disaster_message ~set_disaster_message =
  let%arr disaster_message = disaster_message
  and set_disaster_message = set_disaster_message in
  match disaster_message with
  | None -> Node.none
  | Some msg ->
      Node.div
        ~attrs:
          [
            Attr.class_ "modal-overlay";
            Attr.on_click (fun _ -> set_disaster_message None);
          ]
        [
          Node.div
            ~attrs:[ Attr.class_ "modal" ]
            [
              Node.h2 [ Node.text "Disaster!" ];
              Node.p [ Node.text msg ];
              Node.button
                ~attrs:[ Attr.on_click (fun _ -> set_disaster_message None) ]
                [ Node.text "Close" ];
            ];
        ]

