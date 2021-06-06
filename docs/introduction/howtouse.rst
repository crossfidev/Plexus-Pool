.. _howtouse:

How to use Mineplex
================

This How To illustrates the use of the various Mineplex binaries as well
as some concepts about the network.

The Binaries
------------

After a successful compilation, you should have the following binaries:

- ``mineplex-node``: the mineplex daemon itself;
- ``mineplex-client``: a command-line client and basic wallet;
- ``mineplex-admin-client``: administration tool for the node;
- ``mineplex-{baker,endorser,accuser}-*``: daemons to bake, endorse and
  accuse on the Mineplex network (see :ref:`howtorun`);
- ``mineplex-signer``: a client to remotely sign operations or blocks
  (see :ref:`signer`);

The daemons are suffixed with the name of the protocol that they are
bound to. For instance, ``mineplex-baker-002-Pt4xzupC`` is the baker
for the Main protocol.

Node
----

The node is the main actor of the Mineplex blockchain and it has two main
functions: running the gossip network and updating the context.
The gossip network is where all Mineplex nodes exchange blocks and
operations with each other (see :ref:`mineplex-admin-client` to monitor
p2p connections).
Using this peer-to-peer network, an operation originated by a user can
hop several times through other nodes until it finds its way in a
block baked by a baker.
Using the blocks it receives on the gossip network the shell also
keeps up to date the current `context`, that is the full state of
the blockchain shared by all peers.
Approximately every minute a new block is created and, when the shell
receives it, it applies each operation in the block to its current
context and computes a new context.
The last block received on a chain is also called the `head` of that
chain.
Each new head is then advertised by the node to its peers,
disseminating this information to build a consensus across the
network.

Other than passively observing the network, your node can also inject
its own new operations when instructed by the ``mineplex-client``.
The node has also a view of the multiple chains that may exist
concurrently and selects the best one based on its fitness (see
:ref:`proof-of-stake`).


Node Identity
~~~~~~~~~~~~~

First we need to generate a new identity in order for the node to
connect to the network::

    ./mineplex-node config init --data-dir ~/mineplex-mainnet
    ./mineplex-node identity generate --data-dir ~/mineplex-mainnet

The identity comprises a pair of cryptographic
keys that nodes use to encrypt messages sent to each other, and an
antispam-PoW stamp proving that enough computing power has been
dedicated to creating this identity.
Note that this is merely a network identity and it is not related in
any way to a Mineplex address on the blockchain.

Node Synchronization
~~~~~~~~~~~~~~~~~~~~

Whenever a node starts, it tries to retrieve the most current head of the chain
from its peers. This can be a long process if there are many blocks to retrieve
(e.g. when a node is launched for the first time, or has been out of sync for a
while), or on a slow network connection.

Once the synchronization is complete, the node is said to be *bootstrapped*.
Some operations require the node to be bootstrapped.

.. _node-protocol:

Node Protocol
~~~~~~~~~~~~~

A Mineplex node can switch from one protocol to another during its
execution.  This typically happens during the synchronization phase
when a node launches for the first time. The node starts with the
genesis protocol and then goes through all previous protocols until it
finally switches to the current protocol.

Throughout the documentation, `Alpha` refers to the protocol in the
``src/proto_alpha`` directory of the ``mineplex-beta-protocol`` branch, which is a
copy of the protocol active on Mainnet.


Storage
~~~~~~~

All blockchain data is stored under ``~/mineplex-mainnet/``.

If for some reason your node is misbehaving or there has been an
upgrade of the network, it is safe to remove this directory, it just
means that your node will take some time to resync the chain.

If removing this directory, please note that if it took you a long time to
compute your node identity, keep the ``identity.json`` file and instead only
remove the child ``store`` and ``context`` directories.

If you are also running a baker make sure that it has access to the
``mineplex-mainnet`` directory of the node.


RPC Interface
~~~~~~~~~~~~~

The only interface to the node is through JSON RPC calls and it is disabled by
default.  A more detailed documentation can be found in the :ref:`RPC index.
<rpc>` The RPC interface must be enabled in order for the clients
to communicate with the node, but is should not be publicly accessible on the
internet. With the following command it is available uniquely on the
`localhost` address of your machine, on the default port ``8732``.

::

   ./mineplex-node run  --data-dir ~/mineplex-mainnet --rpc-addr 127.0.0.1:8732 --connections 15 --history-mode=archive

Client
------

Mineplex client can be used to interact with the node, it can query its
status or ask the node to perform some actions.
For example after starting your node you can check if it has finished
synchronizing using::

   ./mineplex-client -endpoint http://127.0.0.1:8732/ bootstrapped

This call will hang and return only when the node is synchronized.
We can now check what is the current timestamp of the head of the
chain (time is in UTC so it may differ from your local)::

   ./mineplex-client -endpoint http://127.0.0.1:8732/ get timestamp

Beware that the commands available on the client depend on the specific
protocol run by the node. For instance, `get timestamp` isn't available when
the node runs the genesis protocol, which may happen for a few minutes when
launching a node for the first time.

A Simple Wallet
~~~~~~~~~~~~~~~

The client is also a basic wallet and after the activation above you
will notice that the directory ``.mineplex-client`` has been populated with
3 files ``public_key_hashs``, ``public_keys`` and ``secret_keys``.
The content of each file is in JSON and keeps the mapping between
aliases (``alice`` in our case) and what you would expect from the name
of the file.
Secret keys are stored on disk encrypted with a password except when
using a hardware wallet (see :ref:`ledger`).

We can for example generate a new pair of keys, which can be used locally
with the alias *bob*::

      $ ./mineplex-client -endpoint http://127.0.0.1:8732/ gen keys bob

To check the contract has been created::

      $ ./mineplex-client -endpoint http://127.0.0.1:8732/ list known contracts

Mineplex support three different ECC schemes: *Ed25519*, *secp256k1* (the
one used in Bitcoin), and *P-256* (also called *secp256r1*). The two
latter curves have been added for interoperability with Bitcoin and
Hardware Security Modules (*HSMs*) mostly. Unless your use case
require those, you should probably use *Ed25519*. We use a verified
library for Ed25519, and it is generally recommended over other curves
by the crypto community, for performance and security reasons.

Make sure to make a back-up of this directory and that the password
protecting your secret keys is properly managed.

For more advanced key management we offer :ref:`ledger support
<ledger>` and a :ref:`remote signer<signer>`.


.. _faucet:

Check Mine or Plex balance
~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's check the mine balance of the new account with::

    ./mineplex-client -endpoint http://127.0.0.1:8732/ get mine_balance for alice

To check plex balance of the account please use::

    ./mineplex-client -endpoint http://127.0.0.1:8732/ get balance for alice

Transfers and Receipts
~~~~~~~~~~~~~~~~~~~~~~

In order to fund our newly created account we need to transfer some
mine or plex using the `mine_trasfer` or `transfer` operation.
Every operation returns a `receipt` that recapitulates all the effects
of the operation on the blockchain.
A useful option for any operation is ``--dry-run``, which instructs
the client to simulate the operation without actually sending it to
the network, so that we can inspect its receipt.

Let's try::

  ./mineplex-client -endpoint http://127.0.0.1:8732/ mine_transfer 1 from alice to bob --dry-run

  Fatal error:
    The operation will burn 0.257 MINE which is higher than the configured burn cap (0 MINE).
     Use `--burn-cap 0.257` to emit this operation.

The client asks the node to validate the operation (without sending
it) and obtains an error.
The reason is that when we fund a new address we are also creating it
on the blockchain.
Any storage on chain has a cost associated to it which should be
accounted for either by paying a fee to a baker or by destroying
(`burning`) some MINE.
This is particularly important to protect the system from spam.
Because creating an address requires burning 0.257 MINE and the client has
a default of 0, we need to explicitly set a cap on the amount that we
allow to burn::

  ./mineplex-client -endpoint http://127.0.0.1:8732/ mine_transfer 1 from alice to bob --dry-run --burn-cap 0.257

Surprisingly, our transfer operation resulted in `two` operations,
first a `revelation` and then a transfer.
Alice's address, obtained from the faucet, is already present on the
blockchain, but only in the form of a `public key hash`
``mp1Rj...5w``.
In order to sign operations Alice needs to first reveal the `public
key` ``edpkuk...3X`` behind the hash, so that other users can verify
her signatures.
The client is kind enough to prepend a reveal operation before the
first transfer of a new address, this has to be done only once, future
transfers will consist of a single operation as expected.

Now that we have a clear picture of what we are going to pay we can
execute the transfer for real, without the dry-run option.
You will notice that the client hangs for a few seconds before
producing the receipt because after injecting the operation in your
local node it is waiting for it to be included by some baker on the
network.
Once it receives a block with the operation inside it will return the
receipt.

It is advisable to wait several blocks to consider the transaction as
final, for an important operation we advice to wait 60 blocks.

In the rare case when an operation is lost, how can we be sure that it
will not be included in any future block and re-emit it?
After 60 blocks a transaction is considered invalid and can't be
included anymore in a block.
Furthermore each operation has a counter (explained in more detail
later) that prevents replays so it is usually safe to re-emit an
operation that seems lost.

Validation
~~~~~~~~~~

The node allows to validate an operation before submitting it to the
network by simply simulating the application of the operation to the
current context.
In general if you just send an invalid operation e.g. sending more
tokens that what you own, the node will broadcast it and when it is
included in a block you'll have to pay the usual fee even if it won't
have an affect on the context.
To avoid this case the client first asks the node to validate the
transaction and then sends it.

The same validation is used when you pass the option ``--dry-run``,
the receipt that you see is actually a simulated one.

Another important use of validation is to determine gas and storage
limits.
The node first simulates the execution of a Michelson program and
takes trace of the amount of gas and storage.
Then the client sends the transaction with the right limits for gas
and storage based on that indicated by the node.
This is why we were able to submit transactions without specifying
this limits, they were computed for us.

It's RPCs all the Way Down
~~~~~~~~~~~~~~~~~~~~~~~~~~

The client communicates with the node uniquely through RPC calls so
make sure that the node is listening and that the ports are
correct.
For example the ``get timestamp`` command above is a shortcut for::

   ./mineplex-client -endpoint http://127.0.0.1:8732/ rpc get /chains/main/blocks/head/header/shell

The client tries to simplify common tasks as much as possible, however
if you want to query the node for more specific information you'll
have to resort to RPCs. For example to check the value of important
constants in Mineplex, which may differ between Mainnet and other
:ref:`test networks<test-networks>`, you can use::

   ./mineplex-client -endpoint http://127.0.0.1:8732/ rpc get /chains/main/blocks/head/context/constants | jq
   {
      "proof_of_work_nonce_size": 8,
      "nonce_length": 32,
      "max_revelations_per_block": 32,
      "max_operation_data_length": 16384,
      "max_proposals_per_delegate": 20,
      "preserved_cycles": 5,
      "blocks_per_cycle": 1440,
      "blocks_per_commitment": 32,
      "blocks_per_roll_snapshot": 256,
      "blocks_per_voting_period": 32768,
      "time_between_blocks": [
        "60",
        "40"
      ],
      "endorsers_per_block": 30,
      "hard_gas_limit_per_operation": "1040000",
      "hard_gas_limit_per_block": "10400000",
      "proof_of_work_threshold": "70368744177663",
      "tokens_per_roll": "0",
      "mine_tokens_per_roll": "1000000000000",
      "michelson_maximum_type_size": 1000,
      "seed_nonce_revelation_tip": "0",
      "origination_size": 257,
      "block_security_deposit": "60000000000",
      "endorsement_security_deposit": "2000000000",
      "baking_reward_per_endorsement": [
        "10000000",
        "1500000"
      ],
      "endorsement_reward": [
        "10000000",
        "6666000"
      ],
      "cost_per_byte": "1000",
      "hard_storage_limit_per_operation": "60000",
      "test_chain_duration": "1966080",
      "quorum_min": 2000,
      "quorum_max": 7000,
      "min_proposal_quorum": 500,
      "initial_endorsers": 24,
      "delay_per_missing_endorsement": "8"
    }

Another interesting use of RPCs is to inspect the receipts of the
operations of a block::

  ./mineplex-client -endpoint http://127.0.0.1:8732/ rpc get /chains/main/blocks/head/operations

It is also possible to review the receipt of the whole block::

  ./mineplex-client -endpoint http://127.0.0.1:8732/ rpc get /chains/main/blocks/head/metadata

An interesting block receipt is the one produced at the end of a
cycle as many delegates receive back part of their unfrozen accounts.