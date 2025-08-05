val component :
            disaster_message:string option Bonsai.Value.t ->
            set_disaster_message:('a option -> unit Ui_effect.t)
                                 Bonsai.Value.t ->
            set_burned_positions:('b option -> unit Ui_effect.t)
                                 Bonsai.Value.t ->
            burned_positions:Game_strategies_common_lib.Position.t list
                             option Bonsai.Value.t ->
            game:Game_strategies_common_lib.Game.t Bonsai.Value.t ->
            set_game:(Game_strategies_common_lib.Game.t -> unit Ui_effect.t)
                     Bonsai.Value.t ->
            Virtual_dom__Node.t Bonsai.Computation.t