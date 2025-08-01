val component :
  is_game_over:bool Value.t ->
  on_restart:(unit -> unit Effect.t) ->
  Vdom.Node.t Computation.t
