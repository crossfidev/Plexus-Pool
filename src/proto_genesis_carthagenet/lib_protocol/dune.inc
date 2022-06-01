

;
;        /!\ /!\ Do not modify this file /!\ /!\
;
; but the original template in `mineplex-protocol-compiler`
;


(rule
 (targets environment.ml)
 (action
  (write-file %{targets}
              "module Name = struct let name = \"genesis-carthagenet\" end
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
                  (chdir %{workspace_root} (run %{bin:mineplex-embedded-protocol-packer} "%{src_dir}" "genesis_carthagenet")))))

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
    "module Environment = mineplex_protocol_environment_genesis_carthagenet.Environment
let hash = mineplex_crypto.Protocol_hash.of_b58check_exn \"PtYuensgYBb3G3x1hLLbCmcav8ue8Kyd2khADcL5LsT5R1hcXex\"
let name = Environment.Name.name
include mineplex_raw_protocol_genesis_carthagenet
include mineplex_raw_protocol_genesis_carthagenet.Main
")))

(library
 (name mineplex_protocol_environment_genesis_carthagenet)
 (public_name mineplex-protocol-genesis-carthagenet.environment)
 (library_flags (:standard -linkall))
 (libraries mineplex-protocol-environment)
 (modules Environment))

(library
 (name mineplex_raw_protocol_genesis_carthagenet)
 (public_name mineplex-protocol-genesis-carthagenet.raw)
 (libraries mineplex_protocol_environment_genesis_carthagenet)
 (library_flags (:standard -linkall))
 (flags (:standard -nopervasives -nostdlib
                   -w +a-4-6-7-9-29-32-40..42-44-45-48
                   -warn-error +a
                   -open mineplex_protocol_environment_genesis_carthagenet__Environment
                   -open Pervasives
                   -open Error_monad))
 (modules
   Data
   Services
   Main))

(install
 (section lib)
 (package mineplex-protocol-genesis-carthagenet)
 (files (mineplex_PROTOCOL as raw/mineplex_PROTOCOL)))

(library
 (name mineplex_protocol_genesis_carthagenet)
 (public_name mineplex-protocol-genesis-carthagenet)
 (libraries
      mineplex-protocol-environment
      mineplex-protocol-environment-sigs
      mineplex_raw_protocol_genesis_carthagenet)
 (flags -w "+a-4-6-7-9-29-40..42-44-45-48"
        -warn-error "+a"
        -nopervasives)
 (modules Protocol))

(library
 (name mineplex_protocol_genesis_carthagenet_functor)
 (public_name mineplex-protocol-genesis-carthagenet.functor)
 (libraries
      mineplex-protocol-environment
      mineplex-protocol-environment-sigs
      mineplex_raw_protocol_genesis_carthagenet)
 (flags -w "+a-4-6-7-9-29-40..42-44-45-48"
        -warn-error "+a"
        -nopervasives)
 (modules Functor))

(library
 (name mineplex_embedded_protocol_genesis_carthagenet)
 (public_name mineplex-embedded-protocol-genesis-carthagenet)
 (library_flags (:standard -linkall))
 (libraries mineplex-protocol-genesis-carthagenet
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
 (deps .mineplex_protocol_genesis_carthagenet.objs/native/mineplex_protocol_genesis_carthagenet.cmx))

(alias
 (name runtest)
 (package mineplex-protocol-genesis-carthagenet)
 (deps (alias runtest_sandbox)))
