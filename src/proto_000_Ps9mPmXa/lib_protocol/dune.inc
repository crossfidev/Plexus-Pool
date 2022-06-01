

;
;        /!\ /!\ Do not modify this file /!\ /!\
;
; but the original template in `mineplex-protocol-compiler`
;


(rule
 (targets environment.ml)
 (action
  (write-file %{targets}
              "module Name = struct let name = \"000-Ps9mPmXa\" end
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
                  (chdir %{workspace_root} (run %{bin:mineplex-embedded-protocol-packer} "%{src_dir}" "000_Ps9mPmXa")))))

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
    "module Environment = mineplex_protocol_environment_000_Ps9mPmXa.Environment
let hash = mineplex_crypto.Protocol_hash.of_b58check_exn \"Ps9mPmXaRzmzk35gbAYNCAw6UXdE2qoABTHbN2oEEc1qM7CwT9P\"
let name = Environment.Name.name
include mineplex_raw_protocol_000_Ps9mPmXa
include mineplex_raw_protocol_000_Ps9mPmXa.Main
")))

(library
 (name mineplex_protocol_environment_000_Ps9mPmXa)
 (public_name mineplex-protocol-000-Ps9mPmXa.environment)
 (library_flags (:standard -linkall))
 (libraries mineplex-protocol-environment)
 (modules Environment))

(library
 (name mineplex_raw_protocol_000_Ps9mPmXa)
 (public_name mineplex-protocol-000-Ps9mPmXa.raw)
 (libraries mineplex_protocol_environment_000_Ps9mPmXa)
 (library_flags (:standard -linkall))
 (flags (:standard -nopervasives -nostdlib
                   -w +a-4-6-7-9-29-32-40..42-44-45-48
                   -warn-error +a
                   -open mineplex_protocol_environment_000_Ps9mPmXa__Environment
                   -open Pervasives
                   -open Error_monad))
 (modules
   Data
   Services
   Main))

(install
 (section lib)
 (package mineplex-protocol-000-Ps9mPmXa)
 (files (mineplex_PROTOCOL as raw/mineplex_PROTOCOL)))

(library
 (name mineplex_protocol_000_Ps9mPmXa)
 (public_name mineplex-protocol-000-Ps9mPmXa)
 (libraries
      mineplex-protocol-environment
      mineplex-protocol-environment-sigs
      mineplex_raw_protocol_000_Ps9mPmXa)
 (flags -w "+a-4-6-7-9-29-40..42-44-45-48"
        -warn-error "+a"
        -nopervasives)
 (modules Protocol))

(library
 (name mineplex_protocol_000_Ps9mPmXa_functor)
 (public_name mineplex-protocol-000-Ps9mPmXa.functor)
 (libraries
      mineplex-protocol-environment
      mineplex-protocol-environment-sigs
      mineplex_raw_protocol_000_Ps9mPmXa)
 (flags -w "+a-4-6-7-9-29-40..42-44-45-48"
        -warn-error "+a"
        -nopervasives)
 (modules Functor))

(library
 (name mineplex_embedded_protocol_000_Ps9mPmXa)
 (public_name mineplex-embedded-protocol-000-Ps9mPmXa)
 (library_flags (:standard -linkall))
 (libraries mineplex-protocol-000-Ps9mPmXa
            mineplex-protocol-updater
            mineplex-protocol-environment)
 (flags (:standard -w +a-4-6-7-9-29-32-40..42-44-45-48
                   -warn-error +a))
 (modules Registerer))

(alias
 (name runtest_compile_protocol)
 (action (run %{bin:mineplex-protocol-compiler}  .)))

(alias
 (name runtest_sandbox)
 (deps .mineplex_protocol_000_Ps9mPmXa.objs/native/mineplex_protocol_000_Ps9mPmXa.cmx))

(alias
 (name runtest)
 (package mineplex-protocol-000-Ps9mPmXa)
 (deps (alias runtest_sandbox)))
