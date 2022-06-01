type args = private
  | Baker : string -> args
  | Endorser : string -> args
  | Accuser : args

type t = private
  { node: mineplex_node.t
  ; client: mineplex_client.t
  ; exec: mineplex_executable.t
  ; args: args
  ; name_tag: string option }

val of_node :
     ?name_tag:string
  -> mineplex_node.t
  -> args
  -> exec:mineplex_executable.t
  -> client:mineplex_client.t
  -> t

val baker_of_node :
     ?name_tag:string
  -> mineplex_node.t
  -> key:string
  -> exec:mineplex_executable.t
  -> client:mineplex_client.t
  -> t

val endorser_of_node :
     ?name_tag:string
  -> mineplex_node.t
  -> key:string
  -> exec:mineplex_executable.t
  -> client:mineplex_client.t
  -> t

val accuser_of_node :
     ?name_tag:string
  -> mineplex_node.t
  -> exec:mineplex_executable.t
  -> client:mineplex_client.t
  -> t

val arg_to_string : args -> string

val to_script :
     < env_config: Environment_configuration.t ; paths: Paths.t ; .. >
  -> t
  -> unit Genspio.Language.t

val process :
     < env_config: Environment_configuration.t ; paths: Paths.t ; .. >
  -> t
  -> Running_processes.Process.t
