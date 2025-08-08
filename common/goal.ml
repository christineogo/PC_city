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
    id = "build-housing-5";
    description = "Build 5 houses";
    reward = 200;
  };
  {
    id = "build-business-3";
    description = "Build 3 retail buildings";
    reward = 250;
  };
  {
    id = "earn-2000-money";
    description = "Accumulate $2000";
    reward = 300;
  };
  {
    id = "implement-any-policy";
    description = "Implement your first policy";
    reward = 300;
  };
  {
    id = "build-university";
    description = "Build a University";
    reward = 600;
  };
    {
    id = "reach-100-pop";
    description = "Reach 100 Population";
    reward = 200;
  };
  {
    id = "reach-500-pop";
    description = "Reach 500 Population";
    reward = 500;
  };
  {
    id = "implement-3-policies";
    description = "Implement 3 different policies";
    reward = 900;
  };
  {
    id = "reach-2000-pop";
    description = "Reach 2000 Population";
    reward = 1000;
  };
  {
    id = "smart-city";
    description = "Build a University, Hospital, Police, and Fire Station";
    reward = 1200;
  };
  (* Add more as needed *)
]
