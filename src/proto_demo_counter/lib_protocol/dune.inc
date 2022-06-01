

;
;        /!\ /!\ Do not modify this file /!\ /!\
;
; but the original template in `mineplex-protocol-compiler`
;


(rule
 (targets environment.ml)
 (action
  (write-file %{targets}
              "module Name = struct let name = \"demo-counter\" end
include mineplex_protocol_environment.MakeV0(Name)()
module CamlinternalFormatBasics = struct include CamlinternalFormatBasics end
")))

(rule
 (targets registerer.ml)
 (deps
   error.mli error.ml
   proto_params.mli proto_params.ml
   header.mli header.ml
   state.mli state.ml
   proto_operation.mli proto_operation.ml
   receipt.mli receipt.ml
   apply.mli apply.ml
   services.mli services.ml
   main.mli main.ml
   (:src_dir mineplex_PROTOCOL))
 (action
  (with-stdout-to %{targets}
                  (chdir %{workspace_root} (run %{bin:mineplex-embedded-protocol-packer} "%{src_dir}" "demo_counter")))))

(rule
 (targets functor.ml)
 (deps
   error.mli error.ml
   proto_params.mli proto_params.ml
   header.mli header.ml
   state.mli state.ml
   proto_operation.mli proto_operation.ml
   receipt.mli receipt.ml
   apply.mli apply.ml
   services.mli services.ml
   main.mli main.ml
   (:src_dir mineplex_PROTOCOL))
 (action (with-stdout-to %{targets}
                         (chdir %{workspace_root}
                                (run %{bin:mineplex-protocol-compiler.mineplex-protocol-packer} %{src_dir})))))

(rule
 (targets protocol.ml)
 (deps
   error.mli error.ml
   proto_params.mli proto_params.ml
   header.mli header.ml
   state.mli state.ml
   proto_operation.mli proto_operation.ml
   receipt.mli receipt.ml
   apply.mli apply.ml
   services.mli services.ml
   main.mli main.ml)
 (action
  (write-file %{targets}
    "module Environment = mineplex_protocol_environment_demo_counter.Environment
let hash = mineplex_crypto.Protocol_hash.of_b58check_exn \"ProtoDemoCounterDemoCounterDemoCounterDemoCou4LSpdT\"
let name = Environment.Name.name
include mineplex_raw_protocol_demo_counter
include mineplex_raw_protocol_demo_counter.Main
")))

(library
 (name mineplex_protocol_environment_demo_counter)
 (public_name mineplex-protocol-demo-counter.environment)
 (library_flags (:standard -linkall))
 (libraries mineplex-protocol-environment)
 (modules Environment))

(library
 (name mineplex_raw_protocol_demo_counter)
 (public_name mineplex-protocol-demo-counter.raw)
 (libraries mineplex_protocol_environment_demo_counter)
 (library_flags (:standard -linkall))
 (flags (:standard -nopervasives -nostdlib
                   -w +a-4-6-7-9-29-32-40..42-44-45-48
                   -warn-error +a
                   -open mineplex_protocol_environment_demo_counter__Environment
                   -open Pervasives
                   -open Error_monad))
 (modules
   Error
   Proto_params
   Header
   State
   Proto_operation
   Receipt
   Apply
   Services
   Main))

(install
 (section lib)
 (package mineplex-protocol-demo-counter)
 (files (mineplex_PROTOCOL as raw/mineplex_PROTOCOL)))

(library
 (name mineplex_protocol_demo_counter)
 (public_name mineplex-protocol-demo-counter)
 (libraries
      mineplex-protocol-environment
      mineplex-protocol-environment-sigs
      mineplex_raw_protocol_demo_counter)
 (flags -w "+a-4-6-7-9-29-40..42-44-45-48"
        -warn-error "+a"
        -nopervasives)
 (modules Protocol))

(library
 (name mineplex_protocol_demo_counter_functor)
 (public_name mineplex-protocol-demo-counter.functor)
 (libraries
      mineplex-protocol-environment
      mineplex-protocol-environment-sigs
      mineplex_raw_protocol_demo_counter)
 (flags -w "+a-4-6-7-9-29-40..42-44-45-48"
        -warn-error "+a"
        -nopervasives)
 (modules Functor))

(library
 (name mineplex_embedded_protocol_demo_counter)
 (public_name mineplex-embedded-protocol-demo-counter)
 (library_flags (:standard -linkall))
 (libraries mineplex-protocol-demo-counter
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
 (deps .mineplex_protocol_demo_counter.objs/native/mineplex_protocol_demo_counter.cmx))

(alias
 (name runtest)
 (package mineplex-protocol-demo-counter)
 (deps (alias runtest_sandbox)))
