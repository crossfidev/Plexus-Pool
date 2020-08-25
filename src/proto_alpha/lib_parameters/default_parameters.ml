(*****************************************************************************)
(*                                                                           *)
(* Open Source License                                                       *)
(* Copyright (c) 2018 Dynamic Ledger Solutions, Inc. <contact@tezos.com>     *)
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
      blocks_per_voting_period = 32768l;
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
      block_security_deposit = Mine_repr.(mul_exn one 60000);
      endorsement_security_deposit = Mine_repr.(mul_exn one 2000);
      baking_reward_per_endorsement =
        Tez_repr.[of_mutez_exn 10_000_000L; of_mutez_exn 1_500_000L];
      endorsement_reward =
        Tez_repr.[of_mutez_exn 10_000_000L; of_mutez_exn 6_666_000L];
      hard_storage_limit_per_operation = Z.of_int 60_000;
      cost_per_byte = Mine_repr.of_mutez_exn 1_000L;
      test_chain_duration = Int64.mul 32768L 60L;
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

let bootstrap_accounts_strings =
  [ "edpktyrhPtpHe9L99NrTCMCAqPLJeLB5d93qDThhtz8noE68kAACQr";
    "edpkuBaqbY28mt1ycXoW4sai1L4uyRjaa6BmLgjiHAWEFQ3k14yVpb";
    "edpkuVrEh8PgvPhNpraufKJF45NQ76pGbhWBHfsRFQ1gL7tXQF9B5Y";
    "edpku5or2xS8BQ2deKoA2htmDZ4tyQptQ4USpAkqX4raLRBGHY62Yu";
    "edpku6G3HftKoxMjMSwR9NyV3TatjbDsq4QqV1ycVu53Lmjhs8iSbP" ]

let mine_bootstrap_balance = Mine_repr.of_mutez_exn 8_000_000_000_000L
let bootstrap_balance = Tez_repr.of_mutez_exn 1L

let bootstrap_accounts =
  List.map
    (fun s ->
      let public_key = Signature.Public_key.of_b58check_exn s in
      let public_key_hash = Signature.Public_key.hash public_key in
      Parameters_repr.
        {
          public_key_hash;
          public_key = Some public_key;
          amount = bootstrap_balance;
          mine_amount = mine_bootstrap_balance;
        })
    bootstrap_accounts_strings

(* TODO this could be generated from OCaml together with the faucet
   for now these are hardcoded values in the tests *)
let commitments =
  let json_result =
    Data_encoding.Json.from_string
      {json|
  [
    [ "bmp1U7vHEGkuNbGYg42nUV9qL18aCrJf983Ji", "80000000000" ],
    [ "bmp1Cx9gmg4ASQTkwdrjG1vQkiyCDMa3CDJ4C", "80000000000" ],
    [ "bmp1DJBB2ZryDW1ZKK8V8uhaziGVWSWr4T39E", "80000000000" ],
    [ "bmp16ktx4babeeYuq79DZgNphCRcVDFp6xBL1", "80000000000" ],
    [ "bmp1FB2BMGcbq3r9ZtxdMxjG9GgxfCHBCzwBw", "80000000000" ]
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
