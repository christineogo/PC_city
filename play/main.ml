open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

let component = 
  let%sub title = Bonsai.const (Vdom.Node.text "PC City") in
  let%sub grid = Grid.component in 
  let%sub button = Bonsai.const (Vdom.Node.button [Vdom.Node.text "Start Game"]) in 

  let%arr title = title and grid = grid and button = button in 
  View.vbox [title; button; grid] 

let () = Bonsai_web.Start.start component