open! Bonsai_web

val component :
  game:Game_strategies_common_lib.Game.t Value.t ->
  set_game:(Game_strategies_common_lib.Game.t -> unit Effect.t) Value.t ->
  message:string option Value.t ->
  on_restart:unit Effect.t Value.t ->
  Virtual_dom.Vdom.Node.t Computation.t
