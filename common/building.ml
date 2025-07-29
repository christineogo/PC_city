open! Core

module T = struct
  type t = Police | Electricity | Fire | House | University | School | Grocery | Retail | Apartment | Greenspace | Water | Hospital 
  [@@deriving sexp, equal, compare, bin_io, enumerate]
end

include T
include Comparable.Make_binable (T)

let colors = [
    ("#888888", University);
    ("#f4a261", School);
    ("#a8d5a2", Grocery);
    ("#e76f51", Retail);
    ("#b38728", House);
    ("#8c5a2f", Apartment);
    ("#2a5d00", Greenspace); 
    ("#f4d35e", Electricity);
    ("#4a90e2", Water);
    ("#22303c", Police);
    ("#ffffff", Hospital);
    ("#e63946", Fire)]

let of_string = Fn.compose t_of_sexp Sexp.of_string
let to_string = Fn.compose Sexp.to_string_hum sexp_of_t

let get_color building =
      match List.find colors ~f:(fun (_color, building_type) -> (building_type = building))with
      | Some (color, _) -> color
      | None -> "#D3D3D3" 
