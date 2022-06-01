

;
;        /!\ /!\ Do not modify this file /!\ /!\
;
; but the original template in `mineplex-protocol-compiler`
;


(rule
 (targets environment.ml)
 (action
  (write-file %{targets}
              "module Name = struct let name = \"demo-noops\" end
include mineplex_protocol_environment.MakeV0(Name)()
module CamlinternalFormatBasics = struct include CamlinternalFormatBasics end
")))

(rule
 (targets registerer.ml)
 (deps
   main.mli main.ml
   (:src_dir mineplex_PROTOCOL))
 (action
  (with-stdout-to %{targets}
                  (chdir %{workspace_root} (run %{bin:mineplex-embedded-protocol-packer} "%{src_dir}" "demo_noops")))))

(rule
 (targets functor.ml)
 (deps
   main.mli main.ml
   (:src_dir mineplex_PROTOCOL))
 (action (with-stdout-to %{targets}
                         (chdir %{workspace_root}
                                (run %{bin:mineplex-protocol-compiler.mineplex-protocol-packer} %{src_dir})))))

(rule
 (targets protocol.ml)
 (deps
   main.mli main.ml)
 (action
  (write-file %{targets}
    "module Environment = mineplex_protocol_environment_demo_noops.Environment
let hash = mineplex_crypto.Protocol_hash.of_b58check_exn \"ProtoDemoNoopsDemoNoopsDemoNoopsDemoNoopsDemo6XBoYp\"
let name = Environment.Name.name
include mineplex_raw_protocol_demo_noops
include mineplex_raw_protocol_demo_noops.Main
")))

(library
 (name mineplex_protocol_environment_demo_noops)
 (public_name mineplex-protocol-demo-noops.environment)
 (library_flags (:standard -linkall))
 (libraries mineplex-protocol-environment)
 (modules Environment))

(library
 (name mineplex_raw_protocol_demo_noops)
 (public_name mineplex-protocol-demo-noops.raw)
 (libraries mineplex_protocol_environment_demo_noops)
 (library_flags (:standard -linkall))
 (flags (:standard -nopervasives -nostdlib
                   -w +a-4-6-7-9-29-32-40..42-44-45-48
                   -warn-error +a
                   -open mineplex_protocol_environment_demo_noops__Environment
                   -open Pervasives
                   -open Error_monad))
 (modules
   Main))

(install
 (section lib)
 (package mineplex-protocol-demo-noops)
 (files (mineplex_PROTOCOL as raw/mineplex_PROTOCOL)))

(library
 (name mineplex_protocol_demo_noops)
 (public_name mineplex-protocol-demo-noops)
 (libraries
      mineplex-protocol-environment
      mineplex-protocol-environment-sigs
      mineplex_raw_protocol_demo_noops)
 (flags -w "+a-4-6-7-9-29-40..42-44-45-48"
        -warn-error "+a"
        -nopervasives)
 (modules Protocol))

(library
 (name mineplex_protocol_demo_noops_functor)
 (public_name mineplex-protocol-demo-noops.functor)
 (libraries
      mineplex-protocol-environment
      mineplex-protocol-environment-sigs
      mineplex_raw_protocol_demo_noops)
 (flags -w "+a-4-6-7-9-29-40..42-44-45-48"
        -warn-error "+a"
        -nopervasives)
 (modules Functor))

(library
 (name mineplex_embedded_protocol_demo_noops)
 (public_name mineplex-embedded-protocol-demo-noops)
 (library_flags (:standard -linkall))
 (libraries mineplex-protocol-demo-noops
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
 (deps .mineplex_protocol_demo_noops.objs/native/mineplex_protocol_demo_noops.cmx))

(alias
 (name runtest)
 (package mineplex-protocol-demo-noops)
 (deps (alias runtest_sandbox)))
