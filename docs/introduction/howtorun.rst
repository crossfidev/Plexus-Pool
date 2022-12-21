.. _howtorun:

How to run Mineplex
================

In this section we discuss how to take part in the protocol that runs
the network.
There are two main ways to participate in the consensus, delegating
your coins and running a delegate.
To learn more about the protocol refer to :ref:`this section <proof-of-stake>`.


Delegating your coins
---------------------

If you don't want to deal with the complexity of running your own
delegate, you can always take part in the protocol by delegating your
coins to one.

Implicit accounts can have a
delegate. Setting or resetting the delegate of an implicit account is
achieved by the following command:

::

   ./mineplex-client -endpoint http://127.0.0.1:8732/ set delegate for <implicit_account> to <delegate>

where ``<implicit_account>`` is the address or alias of the implicit
account to delegate and ``<delegate>`` is the address or alias of the
delegate (which has to be :ref:`registered<DelegateRegistration>`).

To stop a delegation, the following command can be used:

::

   ./mineplex-client -endpoint http://127.0.0.1:8732/ withdraw delegate from <implicit_account>



Notice that only implicit accounts can be delegates, so your delegate
must be a *mp* address.

Funds in implicit accounts which are not registered as delegates
do not participate in baking.


Running a delegate
------------------

A delegate is responsible for baking blocks, endorsing blocks and
accusing other delegates in case they try to double bake or double
endorse.

In the network, rights for baking and endorsing are randomly assigned
to delegates proportionally to the number of rolls they have been
delegated.
A roll is just a block of 1.000.000 MINE and all computations with rolls are
rounded to the nearest lower integer e.g. if you have 1.500.000 MINE it amounts
to 1 roll.

Deposits and over-delegation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When baking or endorsing a block, a *security deposit* (or *bond*) is
frozen for ``preserved_cycles`` cycles from the account of the
delegate.
Hence a delegate must have enough funds to be able to pay security
deposits for all the blocks it can potentially bake/endorse during
``preserved_cycles``.
The current deposits are *60.000 MINE* for baked block and *2.000 MINE* for
endorsement.
Note that being delegated coins doesn't mean that a delegate can spend
them, they only add up to its rolls count while all the deposits must
come from the delegate's account.

If a delegate runs out of funds to deposit it won't be able to bake or
endorse. Other than being a missed opportunity for them, this has also
negative consequences on the network.
Missing baking slots slows the network, as it is necessary to wait 40
seconds for the baker at priority 2 to bake, while missing endorsements
reduce the fitness of the chain, making it more susceptible to forks.
Running out of funds can happen if a delegate is *over-delegated*,
that is if the amount of rolls it was delegate is disproportionate
with respect to its available funds.
It is the responsibility of every delegator to make sure a delegate is
not already over-delegated (a delegate cannot refuse a delegation) and
each delegate should plan carefully its deposits.

.. _expected_rights:

Expected rights, deposits and rewards
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let's assume we have 1 roll, we want to estimate our chances to bake
or endorse in order to prepare the funds for our deposits.
Our chances depend on how many rolls are currently active in the
network, once we know that we can estimate how many blocks and
endorsements we could be assigned in a cycle.
The number of active rolls can be computed with two RPCs, first we
list all the active delegates with ``delegates?active``, then we sum
all their ``stacking_balance`` and we simply divide by the size of a
roll, 60.000 MINE.

After ``preserved_cycles``, not only does the delegate take back control of
its frozen deposits, but it also receives the rewards for its hard work
which amount to 300 PLEX to bake a block and ``10 MINE / <block_priority>`` for
endorsing a block.
Additionally a baker also receives the fees of the operations it
included in its blocks.
While fees are unfrozen after ``preserved_cycles`` like deposits and
rewards, they participate in the staking balance of the delegate
immediately after the block has been baked.


.. _DelegateRegistration:

Register and check your rights
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to run a delegate you first need to register as one using
your implicit account::

   ./mineplex-client -endpoint http://127.0.0.1:8732/ register key bob as delegate

Once registered, you need to wait ``preserved_cycles + 2 = 7`` cycles
for your rights to be considered.

There is a simple rpc that can be used to check your rights for every
cycle, up to 5 cycles in the future.

::

   ./mineplex-client -endpoint http://127.0.0.1:8732/ rpc get /chains/main/blocks/head/helpers/baking_rights\?cycle=300\&delegate=mp1_xxxxxxxxxxx\&max_priority=2

Sometimes a delegate skips its turn so it is worth considering also
baking rights at priority 2 like in the example above.
There is no priority for endorsements, every missed endorsement is
lost.

Inactive delegates
~~~~~~~~~~~~~~~~~~

If a delegate doesn't show any sign of activity for `preserved_cycles`
it is marked **inactive** and its rights are removed.
This mechanism is important to remove inactive delegates and reallocate
their rights to the active ones so that the network is always working
smoothly.
Normally even a baker with one single roll should perform enough
operations during 5 cycles to remain active.
If for some reason your delegate is marked inactive you can reactivate
it simply by re-registering again like above.

Baker
~~~~~

The baker is a daemon that once connected to an account, computes the
baking rights for that account, collects transactions from the mempool
and bakes a block.
Note that the baker is the only program that needs direct access to
the node data directory for performance reasons.

Let's launch the daemon pointing to the standard node directory and
baking for user *bob*::

   ./mineplex-baker-002-Pt4xzupC run with local node ~/mineplex-mainnet bob --minimal-fees 100000

Endorser
~~~~~~~~

The endorser is a daemon that once connected to an account, computes
the endorsing rights for that account and, upon reception of a new
block, verifies the validity of the block and emits an endorsement
operation.
It can endorse for a specific account or if omitted it endorses for
all accounts.

::

   ./mineplex-endorser-002-Pt4xzupC run

Accuser
~~~~~~~

The accuser is a daemon that monitors all blocks received on all
chains and looks for:

* bakers who signed two blocks at the same level
* endorsers who injected more than one endorsement operation for the
  same baking slot (more details :ref:`here<proof-of-stake>`)

Upon finding such irregularity, it will emit respectively a
double-baking or double-endorsing denunciation operation, which will
cause the offender to loose its security deposit.

::

   ./mineplex-accuser-002-Pt4xzupC run

Remember that having two bakers or endorsers running connected to the
same account could lead to double baking/endorsing and the loss of all
your bonds.
If you are worried about availability of your node when it is its turn to
bake/endorse, there are other ways than duplicating your credentials.
**Never** use the same account on two daemons.