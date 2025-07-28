(* val component : Virtual_dom.Vdom.Node.t Bonsai.Computation.t *)
val component :
            game:Game_strategies_common_lib.Game.t Bonsai.Value.t ->
            set_game:(Game_strategies_common_lib.Game.t -> unit Ui_effect.t)
                     Bonsai.Value.t ->
            selected_cell:(int * int) option Bonsai.Value.t ->
            Virtual_dom__Node.t Bonsai.Computation.t
