open! Core

type t = {
  id : string;
  description : string;
  reward: int;
}
[@@deriving sexp, equal]
let all : t list = [
  {
    id = "build-fire-station";
    description = "Build a Fire Station";
    reward = 500;
  };
  {
    id = "reach-500-pop";
    description = "Reach 500 Population";
    reward = 500;
  };
  (* Add more as needed *)
]
