open! Core

module T = struct
  type t = { row : int; column : int } [@@deriving sexp, equal, bin_io, compare]
end

include T
include Comparable.Make_binable (T)

let to_string = Fn.compose Sexp.to_string_hum sexp_of_t

let in_bounds t =
  let board_length = 100 in
  let open Int.O in
  List.for_all [ t.row; t.column ] ~f:(fun x -> x >= 0 && x < board_length)

let down { row; column } = { row = row + 1; column }
let right { row; column } = { row; column = column + 1 }
let up { row; column } = { row = row - 1; column }
let left { row; column } = { row; column = column - 1 }

let all_offsets =
  let ( >> ) = Fn.compose in
  [
    up; up >> right; right; right >> down; down; down >> left; left; left >> up;
  ]

let create ~row ~col = { row; column = col }
