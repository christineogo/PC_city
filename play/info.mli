val component :
  show:bool Bonsai.Value.t ->
  on_close:(unit -> unit Ui_effect.t) Bonsai.Value.t ->
  Virtual_dom__Node.t Bonsai.Computation.t
