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

let preserved_cycles c =
  let constants = Raw_context.constants c in
  constants.preserved_cycles

let blocks_per_cycle c =
  let constants = Raw_context.constants c in
  constants.blocks_per_cycle

let blocks_per_commitment c =
  let constants = Raw_context.constants c in
  constants.blocks_per_commitment

let blocks_per_roll_snapshot c =
  let constants = Raw_context.constants c in
  constants.blocks_per_roll_snapshot

let blocks_per_voting_period c =
  let level = Raw_context.current_level c in
  if Compare.Int32.((Raw_level_repr.to_int32 level.level) >= 325000l) then
    7200l
  else 
    let constants = Raw_context.constants c in
    constants.blocks_per_voting_period

let time_between_blocks c =
  let constants = Raw_context.constants c in
  constants.time_between_blocks

let endorsers_per_block c =
  let constants = Raw_context.constants c in
  constants.endorsers_per_block

let initial_endorsers c =
  let constants = Raw_context.constants c in
  constants.initial_endorsers

let delay_per_missing_endorsement c =
  let constants = Raw_context.constants c in
  constants.delay_per_missing_endorsement

let hard_gas_limit_per_operation c =
  let constants = Raw_context.constants c in
  constants.hard_gas_limit_per_operation

let hard_gas_limit_per_block c =
  let constants = Raw_context.constants c in
  constants.hard_gas_limit_per_block

let cost_per_byte c =
  let constants = Raw_context.constants c in
  constants.cost_per_byte

let hard_storage_limit_per_operation c =
  let constants = Raw_context.constants c in
  constants.hard_storage_limit_per_operation

let proof_of_work_threshold c =
  let constants = Raw_context.constants c in
  constants.proof_of_work_threshold

let tokens_per_roll c =
  let constants = Raw_context.constants c in
  constants.tokens_per_roll

let mine_tokens_per_roll c =
  let constants = Raw_context.constants c in
  constants.mine_tokens_per_roll

let michelson_maximum_type_size c =
  let constants = Raw_context.constants c in
  constants.michelson_maximum_type_size

let seed_nonce_revelation_tip c =
  let constants = Raw_context.constants c in
  constants.seed_nonce_revelation_tip

let origination_size c =
  let constants = Raw_context.constants c in
  constants.origination_size

let block_security_deposit c =
  let constants = Raw_context.constants c in
  constants.block_security_deposit

let endorsement_security_deposit c =
  let constants = Raw_context.constants c in
  constants.endorsement_security_deposit

let baking_reward_per_endorsement c =
  let constants = Raw_context.constants c in
  let level = Raw_context.current_level c in
  if Compare.Int32.((Raw_level_repr.to_int32 level.level) >= 
    (Int32.add 1_209_600l (Int32.mul constants.blocks_per_cycle (Int32.of_int constants.preserved_cycles)))) then
    List.map
      (fun s -> (match Tez_repr.(s /? 8L) with 
        Ok t -> t | 
        Error _ -> assert false))
      constants.baking_reward_per_endorsement
  else if Compare.Int32.((Raw_level_repr.to_int32 level.level) >= 
    (Int32.add 518_400l (Int32.mul constants.blocks_per_cycle (Int32.of_int constants.preserved_cycles)))) then
    List.map
      (fun s -> (match Tez_repr.(s /? 4L) with 
        Ok t -> t | 
        Error _ -> assert false))
      constants.baking_reward_per_endorsement
  else if Compare.Int32.((Raw_level_repr.to_int32 level.level) >= 
    (Int32.add 172_800l (Int32.mul constants.blocks_per_cycle (Int32.of_int constants.preserved_cycles)))) then
    List.map
      (fun s -> (match Tez_repr.(s /? 2L) with 
        Ok t -> t | 
        Error _ -> assert false))
      constants.baking_reward_per_endorsement
  else
    constants.baking_reward_per_endorsement

let endorsement_reward c =
  let constants = Raw_context.constants c in
  let level = Raw_context.current_level c in
  if Compare.Int32.((Raw_level_repr.to_int32 level.level) >= 
    (Int32.add 1_209_600l (Int32.mul constants.blocks_per_cycle (Int32.of_int constants.preserved_cycles)))) then
    List.map
      (fun s -> (match Tez_repr.(s /? 8L) with 
        Ok t -> t | 
        Error _ -> assert false))
      constants.endorsement_reward
  else if Compare.Int32.((Raw_level_repr.to_int32 level.level) >= 
    (Int32.add 518_400l (Int32.mul constants.blocks_per_cycle (Int32.of_int constants.preserved_cycles)))) then
    List.map
      (fun s -> (match Tez_repr.(s /? 4L) with 
        Ok t -> t | 
        Error _ -> assert false))
      constants.endorsement_reward
  else if Compare.Int32.((Raw_level_repr.to_int32 level.level) >= 
    (Int32.add 172_800l (Int32.mul constants.blocks_per_cycle (Int32.of_int constants.preserved_cycles)))) then
    List.map
      (fun s -> (match Tez_repr.(s /? 2L) with 
        Ok t -> t | 
        Error _ -> assert false))
      constants.endorsement_reward
  else
    constants.endorsement_reward

let test_chain_duration c =
  let level = Raw_context.current_level c in
  if Compare.Int32.((Raw_level_repr.to_int32 level.level) >= 325000l) then
    Int64.mul 7200L 60L
  else 
    let constants = Raw_context.constants c in
    constants.test_chain_duration

let quorum_min c =
  let constants = Raw_context.constants c in
  constants.quorum_min

let quorum_max c =
  let constants = Raw_context.constants c in
  constants.quorum_max

let min_proposal_quorum c =
  let constants = Raw_context.constants c in
  constants.min_proposal_quorum

let parametric c =
  let constants = Raw_context.constants c in
  {constants with 
    baking_reward_per_endorsement = (baking_reward_per_endorsement c); 
    endorsement_reward = (endorsement_reward c);
    blocks_per_voting_period = (blocks_per_voting_period c);
    test_chain_duration = (test_chain_duration c)
  }