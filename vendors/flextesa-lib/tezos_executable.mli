(** This module wraps the type ['kind t] around the notion of
    mineplex-executable: a path to a binary with mineplex-specific properties. *)

(** Helper functions to construct exec-style command lines for
    ["mineplex-*"] applications. *)
module Make_cli : sig
  val flag : string -> string list
  val opt : string -> string -> string list
  val optf : string -> ('a, unit, string, string list) format4 -> 'a
end

(** Manipulate the ["mineplex_EVENTS_CONFIG"] environment variable. *)
module Unix_files_sink : sig
  type t = private {matches: string list option; level_at_least: string}

  val all_notices : t
  val all_info : t
end

type kind = [`Node | `Baker | `Endorser | `Accuser | `Client | `Admin]
(** The type [kind] is used to distinguish ['a t] executables. *)

type t = private
  { kind: kind
  ; binary: string option
  ; unix_files_sink: Unix_files_sink.t option
  ; environment: (string * string) list }
(** The wrapper of the mineplex-executable. *)

val make :
     ?binary:string
  -> ?unix_files_sink:Unix_files_sink.t
  -> ?environment:(string * string) list
  -> kind
  -> t
(** Create a ["mineplex-node"] executable. *)

val kind_string : kind -> string
(** Convert a [kind] to a [string]. *)

val default_binary : t -> string
(** Get the path/name of the default binary for a given kind, e.g.,
    ["mineplex-admin-client"]. *)

val get : t -> string
(** The path to the executable. *)

val call :
     < env_config: Environment_configuration.t ; .. >
  -> t
  -> path:string
  -> string list
  -> unit Genspio.EDSL.t
(** Build a [Genspio.EDSL.t] script to run a mineplex command, the
    [~path] argument is used as a toplevel path for the unix-files
    event-sink (event-logging-framework) and for other local logging
    files. *)

val cli_term :
     ?extra_doc:string
  -> < manpager: Internal_pervasives.Manpage_builder.State.t ; .. >
  -> kind
  -> string
  -> t Cmdliner.Term.t
(** Build a [Cmdliner] term which creates mineplex-executables, the
    second argument is a prefix of option names (e.g. ["mineplex"] for the
    option ["--mineplex-accuser-alpha-binary"]). *)
