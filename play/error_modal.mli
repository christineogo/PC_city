val component :
            error_message:string option Bonsai.Value.t ->
            set_error_message:('a option -> unit Ui_effect.t) Bonsai.Value.t ->
            Virtual_dom__Node.t Bonsai.Computation.t