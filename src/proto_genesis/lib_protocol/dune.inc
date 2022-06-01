

;
;        /!\ /!\ Do not modify this file /!\ /!\
;
; but the original template in `mineplex-protocol-compiler`
;


(rule
 (targets environment.ml)
 (action
  (write-file %{targets}
              "module Name = struct let name = \"genesis\" end
include mineplex_protocol_environment.MakeV0(Name)()
module CamlinternalFormatBasics = struct include CamlinternalFormatBasics end
")))

(rule
 (targets registerer.ml)
 (deps
   data.ml
   services.ml
   main.mli main.ml
   (:src_dir mineplex_PROTOCOL))
 (action
  (with-stdout-to %{targets}
                  (chdir %{workspace_root} (run %{bin:mineplex-embedded-protocol-packer} "%{src_dir}" "genesis")))))

(rule
 (targets functor.ml)
 (deps
   data.ml
   services.ml
   main.mli main.ml
   (:src_dir mineplex_PROTOCOL))
 (action (with-stdout-to %{targets}
                         (chdir %{workspace_root}
                                (run %{bin:mineplex-protocol-compiler.mineplex-protocol-packer} %{src_dir})))))

(rule
 (targets protocol.ml)
 (deps
   data.ml
   services.ml
   main.mli main.ml)
 (action
  (write-file %{targets}
    "module Environment = mineplex_protocol_environment_genesis.Environment
let hash = mineplex_crypto.Protocol_hash.of_b58check_exn \"ProtoGenesisGenesisGenesisGenesisGenesisGenesk612im\"
let name = Environment.Name.name
include mineplex_raw_protocol_genesis
include mineplex_raw_protocol_genesis.Main
")))

(library
 (name mineplex_protocol_environment_genesis)
 (public_name mineplex-protocol-genesis.environment)
 (library_flags (:standard -linkall))
 (libraries mineplex-protocol-environment)
 (modules Environment))

(library
 (name mineplex_raw_protocol_genesis)
 (public_name mineplex-protocol-genesis.raw)
 (libraries mineplex_protocol_environment_genesis)
 (library_flags (:standard -linkall))
 (flags (:standard -nopervasives -nostdlib
                   -w +a-4-6-7-9-29-32-40..42-44-45-48
                   -warn-error +a
                   -open mineplex_protocol_environment_genesis__Environment
                   -open Pervasives
                   -open Error_monad))
 (modules
   Data
   Services
   Main))

(install
 (section lib)
 (package mineplex-protocol-genesis)
 (files (mineplex_PROTOCOL as raw/mineplex_PROTOCOL)))

(library
 (name mineplex_protocol_genesis)
 (public_name mineplex-protocol-genesis)
 (libraries
      mineplex-protocol-environment
      mineplex-protocol-environment-sigs
      mineplex_raw_protocol_genesis)
 (flags -w "+a-4-6-7-9-29-40..42-44-45-48"
        -warn-error "+a"
        -nopervasives)
 (modules Protocol))

(library
 (name mineplex_protocol_genesis_functor)
 (public_name mineplex-protocol-genesis.functor)
 (libraries
      mineplex-protocol-environment
      mineplex-protocol-environment-sigs
      mineplex_raw_protocol_genesis)
 (flags -w "+a-4-6-7-9-29-40..42-44-45-48"
        -warn-error "+a"
        -nopervasives)
 (modules Functor))

(library
 (name mineplex_embedded_protocol_genesis)
 (public_name mineplex-embedded-protocol-genesis)
 (library_flags (:standard -linkall))
 (libraries mineplex-protocol-genesis
            mineplex-protocol-updater
            mineplex-protocol-environment)
 (flags (:standard -w +a-4-6-7-9-29-32-40..42-44-45-48
                   -warn-error +a))
 (modules Registerer))

(alias
 (name runtest_compile_protocol)
 (action (run %{bin:mineplex-protocol-compiler} -no-hash-check .)))

(alias
 (name runtest_sandbox)
 (deps .mineplex_protocol_genesis.objs/native/mineplex_protocol_genesis.cmx))

(alias
 (name runtest)
 (package mineplex-protocol-genesis)
 (deps (alias runtest_sandbox)))
