open! Core 
open! Bonsai_web 
open! Bonsai.Let_syntax 
open! Virtual_dom.Vdom 

let default_value = 0  (*to maintain variable state for now, christine change this when backend is connected*)
let stats_items = [
  ("Population: ", default_value);
  ("Money: ", default_value);
  ("Happiness: ", default_value); 
  ("Day: ", default_value)
]

let component : Node.t Bonsai.Computation.t =
  Bonsai.const (

  (*City stats*)
    Node.div ~attrs:[Attr.class_ "section-box"]
    [
      Node.h3 ~attrs:[Attr.class_ "section-title"] [Node.text "City Stats"];
      Node.div ~attrs:[Attr.class_ "city-stats"]
      (List.map stats_items ~f:(fun (label, value)-> 
        Node.div ~attrs: [Attr.class_ "stats-item"][
          Node.span ~attrs: [Attr.class_ "stats-label"] [Node.text label]; 
          Node.span ~attrs: [Attr.class_ "legend-label"] [Node.text (string_of_int value)]
        ]))
    ]

    (*Public Opinion*)
    
    (* Node.div ~attrs: [Attr.class_ "section-box"]
    [
      Node.h3 ~attrs:[Attr.class_ "section-title"] [Node.text "Public Opinion"]
    ] *)
  )