type feedback_category =
  | Defund_mandatory
  | Clean_power_pos
  | Clean_power_neg
  | High_occupancy
  | High_tax
  | Greenspace_pos
  | Greenspace_neg
  | High_business_ratio
  | Low_business_ratio
  | No_grocery
  | No_schools
[@@deriving sexp, equal]

val defund_mandatory : string list
val clean_power_pos : string list
val clean_power_neg : string list
val high_occupancy : string list
val high_tax : string list
val greenspace_pos : string list
val greenspace_neg : string list
val high_business_ratio : string list
val low_business_ratio : string list
val no_grocery : string list
val get_feedback_for_category : feedback_category -> string list
