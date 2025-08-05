val component :
  show:bool Bonsai_web.Value.t ->
  on_close:(unit -> unit Bonsai_web.Effect.t) Bonsai_web.Value.t ->
  Virtual_dom.Vdom.Node.t Bonsai_web.Computation.t
