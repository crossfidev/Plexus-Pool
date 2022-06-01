(*****************************************************************************)
(*                                                                           *)
(* Open Source License                                                       *)
(* Copyright (c) 2018 Dynamic Ledger Solutions, Inc. <contact@mineplex.com>     *)
(*                                                                           *)
(* Permission is hereby granted, free of charge, to any person obtaining a   *)
(* copy of this software and associated documentation files (the "Software"),*)
(* to deal in the Software without restriction, including without limitation *)
(* the rights to use, copy, modify, merge, publish, distribute, sublicense,  *)
(* and/or sell copies of the Software, and to permit persons to whom the     *)
(* Software is furnished to do so, subject to the following conditions:      *)
(*                                                                           *)
(* The above copyright notice and this permission notice shall be included   *)
(* in all copies or substantial portions of the Software.                    *)
(*                                                                           *)
(* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR*)
(* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  *)
(* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL   *)
(* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER*)
(* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING   *)
(* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER       *)
(* DEALINGS IN THE SOFTWARE.                                                 *)
(*                                                                           *)
(*****************************************************************************)

module type T = sig
  module P : sig
    val hash : Protocol_hash.t

    include mineplex_protocol_environment.PROTOCOL
  end

  include module type of struct
    include P
  end

  module Block_services : module type of struct
    include Block_services.Make (P) (P)
  end

  val complete_b58prefix :
    mineplex_protocol_environment.Context.t -> string -> string list Lwt.t
end

type t = (module T)

let build hash =
  match mineplex_protocol_registerer.Registerer.get hash with
  | None ->
      None
  | Some (V0 protocol) ->
      let (module F) = protocol in
      let module Name = struct
        let name = Protocol_hash.to_b58check hash
      end in
      let module Env = mineplex_protocol_environment.MakeV0 (Name) () in
      Some
        ( module struct
          module Raw = F (Env)

          module P = struct
            let hash = hash

            include Env.Lift (Raw)
          end

          include P
          module Block_services = Block_services.Make (P) (P)

          let complete_b58prefix = Env.Context.complete
        end : T )

module VersionTable = Protocol_hash.Table

let versions : (module T) VersionTable.t = VersionTable.create 20

let sources : Protocol.t VersionTable.t = VersionTable.create 20

let mem hash =
  VersionTable.mem versions hash
  || mineplex_protocol_registerer.Registerer.mem hash

let get hash =
  try Some (VersionTable.find versions hash)
  with Not_found -> (
    match build hash with
    | Some proto ->
        VersionTable.add versions hash proto ;
        Some proto
    | None ->
        None )

type error += Unregistered_protocol of Protocol_hash.t

let () =
  register_error_kind
    `Permanent
    ~id:"registered_protocol.unregistered_protocol"
    ~title:"Unregistered protocol"
    ~description:"No protocol was registered with the requested hash."
    ~pp:(fun fmt hash ->
      Format.fprintf
        fmt
        "@[<hov>No registered protocol with hash:@ %a@]"
        Protocol_hash.pp
        hash)
    Data_encoding.(obj1 (req "protocol_hash" Protocol_hash.encoding))
    (function Unregistered_protocol hash -> Some hash | _ -> None)
    (fun hash -> Unregistered_protocol hash)

let get_result hash =
  match get hash with
  | Some hash ->
      return hash
  | None ->
      fail (Unregistered_protocol hash)

let list () = VersionTable.fold (fun _ p acc -> p :: acc) versions []

let list_embedded () = VersionTable.fold (fun k _ acc -> k :: acc) sources []

let get_embedded_sources_exn hash = VersionTable.find sources hash

let get_embedded_sources hash =
  try Some (get_embedded_sources_exn hash) with Not_found -> None

module type Source_sig = sig
  val hash : Protocol_hash.t option

  val sources : Protocol.t
end

module Register_embedded_V0
    (Env : mineplex_protocol_environment.V0)
    (Proto : Env.Updater.PROTOCOL)
    (Source : Source_sig) =
struct
  let hash =
    match Source.hash with
    | None ->
        Protocol.hash Source.sources
    | Some hash ->
        hash

  module Self = struct
    module P = struct
      let hash = hash

      include Env.Lift (Proto)
    end

    include P
    module Block_services = Block_services.Make (P) (P)

    let complete_b58prefix = Env.Context.complete
  end

  let () =
    VersionTable.add sources hash Source.sources ;
    VersionTable.add versions hash (module Self : T)

  include Self
end
