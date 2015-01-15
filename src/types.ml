open Batteries
open Printf

module FU = FileUtil

(* FBR: encapsulate those into separate modules *)

module Node = struct
  type t = { host: string ;
             port: int    }
  let create host port =
    { host ; port }
  let to_string n =
    sprintf "%s:%d" n.host n.port
end

module Chunk = struct
  let default_size = 1024 * 1024
  type t = { rank: int ;
             (* None if default_size; (Some x) else *)
             size: int64 option }
  let compare c1 c2 =
    BatInt.compare c1.rank c2.rank
end

(* FBR: status: set of files
        file: set of chunks *)

module File = struct
  type t = { name: string ;
             size: int64 ;
             stat: FU.stat ;
             nb_chunks: int }
  let create name size stat nb_chunks =
    { name; size; stat; nb_chunks }
  let compare f1 f2 =
    String.compare f1.name f2.name
end

module FileSet = struct (* extend type with more operations *)
  include Set.Make(File)
  (* FBR: should be private *)
  let dummy_stat = FU.stat "/dev/null"
  let contains_fn fn s =
    let dummy = File.create fn Int64.zero dummy_stat 0 in
    mem dummy s
end

type storage_mode = Raw | Compressed | Signed | Encrypted

type answer = Ok | Error of string
