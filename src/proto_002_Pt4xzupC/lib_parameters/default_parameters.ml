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

open Protocol

let constants_mainnet =
  Constants_repr.
    {
      preserved_cycles = 5;
      blocks_per_cycle = 1440l;
      blocks_per_commitment = 32l;
      blocks_per_roll_snapshot = 256l;
      blocks_per_voting_period = 7200l;
      time_between_blocks = List.map Period_repr.of_seconds_exn [60L; 40L];
      endorsers_per_block = 30;
      hard_gas_limit_per_operation = Z.of_int 1_040_000;
      hard_gas_limit_per_block = Z.of_int 10_400_000;
      proof_of_work_threshold = Int64.(sub (shift_left 1L 46) 1L);
      tokens_per_roll = Tez_repr.zero;
      mine_tokens_per_roll = Mine_repr.(mul_exn one 1_000_000);
      michelson_maximum_type_size = 1000;
      seed_nonce_revelation_tip = Tez_repr.zero;
        (* (match Tez_repr.(one /? 8L) with Ok c -> c | Error _ -> assert false); *)
      origination_size = 257;
      block_security_deposit = Mine_repr.(mul_exn one 6000);
      endorsement_security_deposit = Mine_repr.(mul_exn one 200);
      baking_reward_per_endorsement =
        Tez_repr.[of_mutez_exn 10_000_000L; of_mutez_exn 1_500_000L];
      endorsement_reward =
        Tez_repr.[of_mutez_exn 10_000_000L; of_mutez_exn 6_666_000L];
      hard_storage_limit_per_operation = Z.of_int 60_000;
      cost_per_byte = Mine_repr.of_mutez_exn 1_000L;
      test_chain_duration = Int64.mul 7200L 60L;
      quorum_min = 20_00l;
      (* quorum is in centile of a percentage *)
      quorum_max = 70_00l;
      min_proposal_quorum = 5_00l;
      initial_endorsers = 24;
      delay_per_missing_endorsement = Period_repr.of_seconds_exn 8L;
    }

let constants_sandbox =
  Constants_repr.
    {
      constants_mainnet with
      preserved_cycles = 2;
      blocks_per_cycle = 8l;
      blocks_per_commitment = 4l;
      blocks_per_roll_snapshot = 4l;
      blocks_per_voting_period = 64l;
      time_between_blocks = List.map Period_repr.of_seconds_exn [1L; 0L];
      proof_of_work_threshold = Int64.of_int (-1);
      initial_endorsers = 1;
      delay_per_missing_endorsement = Period_repr.of_seconds_exn 1L;
    }

let constants_test =
  Constants_repr.
    {
      constants_mainnet with
      blocks_per_cycle = 128l;
      blocks_per_commitment = 4l;
      blocks_per_roll_snapshot = 32l;
      blocks_per_voting_period = 256l;
      time_between_blocks = List.map Period_repr.of_seconds_exn [1L; 0L];
      proof_of_work_threshold = Int64.of_int (-1);
      initial_endorsers = 1;
      delay_per_missing_endorsement = Period_repr.of_seconds_exn 1L;
    }

type bootstrap_accounts_strings = { pk : string; mine_amount: Mine_repr.t }

let bootstrap_accounts_strings =
  [ 
    { 
      pk = "edpktyrhPtpHe9L99NrTCMCAqPLJeLB5d93qDThhtz8noE68kAACQr";
      mine_amount = Mine_repr.of_mutez_exn 256_608_000_000_000_000L
    };
    { 
      pk = "edpkuhBnXw3jLAz1fsUrRWwMdEzxULUwwHozQQpRSmhbB1njSRRNeJ"; 
      mine_amount = Mine_repr.of_mutez_exn 72_000_000_000_000L
    };
    { 
      pk = "edpkuqk189GDocesVp9sTNZJi4rL2mdTJf3jrcpdw1x5WzVA3ELWVA"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkuCNTbwVyM52VexJsdLm5J93Wbo8GddkB83MNtgmvokgdNrzVAh"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpktwYJM7QtHvzzrgv1Lqgaif3wZbqJjXmU7e9vr2GuaRMRUUL7MD"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkuBVeNzHpsVhjujndaRU3KkT1DgKcjx6rS3gNPQomtJJ9gURfyE"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkuWoRCbAjov2AJBWkCsogw6AtSwKdiCHXrvXrPJGSscTzaN3VQL"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpku1RkBHHW5KthSjAVjuSFh2FSYGyZ8ddbdwms2SD5je1k4ha8cX"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkvYXrnKJJNC7bCs5Z3gxmSLpaUyWJGhASJxZVeukfuECZzqWUkH"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkutn48twPLT5ziEkQJYoWYHdqXBvrZbHrXwne6FukW1MmzjtPnN"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkuRdy1a53bqoCEmiy5nc9LzEKUFZZwHhyinrj7KoLdB8oAi6qus"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpktnbXfA47jGanZo5Ypcr8R1krL2GAvdyh9n5aYh14oMKduiJZGu"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkv685gwm6JnFiGaygigwSEC5oFFAb2MgooJLjKpWJB7LB6krND2"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkub95XjEbGQWknyF6ShV65BDuG2QJfMYFdJufNQD4hUsMBGPU9p"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkudZ1pfe5sD7Eqiyyyv4PKF1JbiDBva5MGjHPwHR3VYqq4sod1i"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkukAmW7X2mtd6aynGgGxvZSCKf5wAUKKBcbtvtYV19poQna7yJP"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkvNbWjmKrJKYnmuRoowwu7iFGV4m21gicHiUYym5fmcjNkKHtgs"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkvRZLkxLTjrfLpEuhgBfudfgKD4w5BnY4s9W5F5TfQRens7pB3R"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpku9GxxKZwkkUTS1o3CBAKBaZF8XgyXuk3zLkKQ6K3ULiqZwnL5E"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkvJr4Fo5s19uDibQYQpWvgKiEtdA2PzFm8yHthoTL38Roua95G9"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpktuYqEc7grSCVK7GcFuAWdJK7U5riTafdEa7zN5awC9ayzPUpeg"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpktervQif2tGmfUv4ymqsrPYM2jK18hByCo3FnEnAZDtySNYVXyX"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkvXJ9GxLwfS7KqFxo5DojdNf6TjuLNFzhb9EW5JriSAijaPZALN"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpktiVANm5mk4yaRPzKk1KiEmNZM9SHvZYZC2ezivXPZyqK4W2Lsy"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkvHceq2f2XzbEJq6WzafUcfsyLUCTPz2Np5twkHcMLckGUMGon7"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkuY6dGw3y913CJkKMXKNHgX8RaSMPbUD6QSYZ7UdLyknjtkwJY1"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkuyjumZ7htWYceHcjmd9Dvm9PBwTH3YxQvnE2k555nicd1Ui3YK"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkvHF4LTxVu9SPRZNHjWpxyrYbFn1gRaZqEb8ghHh9a82aVb83gz"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkuC6SABjEYdMAhc8e6phK37GirKvVn88k5idKeDaUj3BWgpCnMh"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkvZxufQ7LY9145G1m6VdxLGSjDt8y71YrJTFJBS87FCov6rWL9z"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpku12x8b2oSkjPxg8Q8j3gCvS4ncCxQPNFJF56q8GkJKGYgbs3s3"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
    { 
      pk = "edpkuZGcWz74e33wT4kjqJYrsnG4TiZxAmKVmjHaU7Cp45f9BsWDmf"; 
      mine_amount = Mine_repr.of_mutez_exn 84_000_000_000_000L
    };
  ]

let bootstrap_balance = Tez_repr.zero

let bootstrap_accounts =
  List.map
    (fun s ->
      let public_key = Signature.Public_key.of_b58check_exn s.pk in
      let public_key_hash = Signature.Public_key.hash public_key in
      Parameters_repr.
        {
          public_key_hash;
          public_key = Some public_key;
          amount = bootstrap_balance;
          mine_amount = s.mine_amount;
        })
    bootstrap_accounts_strings

(* TODO this could be generated from OCaml together with the faucet
   for now these are hardcoded values in the tests *)
let commitments =
  let json_result =
    Data_encoding.Json.from_string
      {json|
  [
    [ "bmp1U7vHEGkuNbGYg42nUV9qL18aCrJf983Ji", "2592000000000000" ]
  ]|json}
  in
  match json_result with
  | Error err ->
      raise (Failure err)
  | Ok json ->
      Data_encoding.Json.destruct
        (Data_encoding.list Commitment_repr.encoding)
        json

let make_bootstrap_account (pkh, pk, amount, mine_amount) =
  Parameters_repr.{public_key_hash = pkh; public_key = Some pk; amount; mine_amount}

let parameters_of_constants ?(bootstrap_accounts = bootstrap_accounts)
    ?(bootstrap_contracts = []) ?(with_commitments = false) constants =
  let commitments = if with_commitments then commitments else [] in
  Parameters_repr.
    {
      bootstrap_accounts;
      bootstrap_contracts;
      commitments;
      constants;
      security_deposit_ramp_up_cycles = None;
      no_reward_cycles = None;
    }

let json_of_parameters parameters =
  Data_encoding.Json.construct Parameters_repr.encoding parameters
