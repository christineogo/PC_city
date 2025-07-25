open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

let component = 
  let%sub title = Bonsai.const (Vdom.Node.text "PC City") in
  let%sub grid = Grid.component in 

  let%arr title = title and grid = grid in 
  View.vbox [title; grid] 

let () = Bonsai_web.Start.start component