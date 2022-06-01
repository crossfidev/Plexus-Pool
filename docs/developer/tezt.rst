.. _tezt:

Tezt: OCaml mineplex Test Framework
================================

Tezt is a test framework for mineplex written in OCaml.
It focuses on integration tests that launch external processes
(in particular mineplex nodes and clients).

Its main strengths are:

- tests are written in the same language as mineplex itself (OCaml),
  which reduces context switch for developers;

- tests do not actively poll the node
  as they passively listen to node events instead,
  which results in faster and more reliable tests;

- in verbose mode, logs show the interleaved output of all external processes,
  while the tests are running;

- it should be easy to use and extend.

How to Run Tests
----------------

If you just want to run tests and see whether they succeed, run::

    make tezt

If you need more control, get the list of command-line options as follows::

    dune exec tezt/tests/main.exe -- --help

Command-line options give you control over verbosity and the list of tests to run.
It also allows to to keep temporary files or to keep going with other tests if a test fails.
For instance, here is how to run all tests with tag ``node`` in verbose mode::

    dune exec tezt/tests/main.exe -- --verbose node

And here is how to get the list of tests and their tags::

    dune exec tezt/tests/main.exe -- --list

Architecture
------------

Tezt is composed of some generic, non-mineplex-related modules:

- a small ``Base`` module with some generally useful "pervasive" functions;

- a ``Log`` module to manage the output;

- a ``Process`` module to manage processes — the output of those
  processes is transparently logged;

- a ``Temp`` module to manage temporary files and directories;

- a ``JSON`` module with lightweight combinators to read JSON values;

- a ``Cli`` module which reads command-line options on startup, such
  as the list of tests to run and the verbosity level;

- a ``Test`` module with a ``Test.run`` function, which starts tests and cleans up after them.

Tezt also contains the following mineplex-specific modules:

- a ``Constant`` module with constants such as protocol hashes or identities;

- a ``Client`` module to run client commands;

- a ``Node`` module to run node commands and to manage node daemons;

- an ``RPC`` module with some RPC implementations.

All those modules can be found in directory ``tezt/lib`` of the mineplex repository.

How to Write New Tests
----------------------

The best way to get started is to have a look at existing tests in directory
``tezt/tests`` of the mineplex repository.

Currently, all tests are part of the same binary ``main.exe``.
The source of this module is ``tezt/tests/main.ml``.
This binary runs all tests, but you can restrict the set of tests to run
by specifying tags on the command line, or even the titles of the tests to run
(with the ``--test`` option).

All tests do not have to be implemented in ``tezt/tests/main.ml`` though.
You can of course add more modules and have them be linked into ``main.exe`` together.
The best way to do this is to write your tests as functions and call them from
the main module.

For instance, let's create a new basic test in a new file named ``tezt/tests/basic.ml``:

.. literalinclude:: ../../tezt/tests/basic.ml
   :lines: 29-
   :language: ocaml

Then, let's launch the test from ``tezt/tests/main.ml`` by calling:

.. code-block:: ocaml

    Basic.run ()

Finally, let's try it with::

    dune exec tezt/tests/main.exe -- basic --info

The ``--info`` flag allows you to see the ``Log.info`` messages.
Here is what you should see::

    $ dune exec tezt/tests/main.exe -- basic --info
    [13:45:36.666] Starting test: basic test (archive mode)
    [13:45:37.525] Activated protocol.
    [13:45:38.215] Baked 10 blocks.
    [13:45:38.215] Level is now 11.
    [13:45:38.215] Identity is not empty.
    [13:45:38.231] [SUCCESS] basic test (archive mode)
    [13:45:38.231] Starting test: basic test (full mode)
    [13:45:39.113] Activated protocol.
    [13:45:39.813] Baked 10 blocks.
    [13:45:39.813] Level is now 11.
    [13:45:39.813] Identity is not empty.
    [13:45:39.828] [SUCCESS] basic test (full mode)
    [13:45:39.828] Starting test: basic test (rolling mode)
    [13:45:40.708] Activated protocol.
    [13:45:41.407] Baked 10 blocks.
    [13:45:41.407] Level is now 11.
    [13:45:41.407] Identity is not empty.
    [13:45:41.422] [SUCCESS] basic test (rolling mode)

Detailed Walkthrough of the Basic Test
--------------------------------------

Let's review what our basic test in the previous section does.

- First, we open the Tezt library and its Base module.
  The Base module contains useful functions such as ``let*`` (which is ``Lwt.bind``)
  or ``sf`` (a short-hand for ``Printf.sprintf``).

- Then, we define a function ``run`` which runs one test.
  It is parameterized by the history mode, so it is easy to run this test
  with all three modes (this is what ``run_all`` does).

- Function ``Test.run`` declares a test.
  The ``~__FILE__`` argument gives the source filename so that one can select this
  file with the ``--file`` argument, to only run tests declared in this file.
  Each test has a title which is used in logs and on the command-line with the ``--test``
  option (which allows to run a particular test from its title).
  Each test also has a list of tags.
  We gave our test the tag ``basic`` in particular.
  No other test has this tag, so it is easy to run all of the tests of our new ``Basic``
  module, and only them, by adding ``basic`` on the command-line.

- Function ``Test.run`` takes a function as an argument.
  This function contains the implementation of the test.

- First, we initialize a node with ``Node.init``.
  This creates a node and runs the node command ``identity generate``,
  then ``config init`` and finally ``run``.
  It then waits until the node is ready, and returns the node.
  Note that you do not have to call ``Node.init``.
  For instance, if you want to test the behavior of the node without an identity,
  you can call ``Node.create``, followed by ``Node.config_init`` and ``Node.run``.

- Then, we initialize a client with ``Client.init``.
  We give it a node, which is the node that the client will connect to by default.
  Note that we can still use this client to perform operations on other nodes
  if we want to, it's just convenient to specify it once and for all.

- Then, we activate the protocol with the ``activate protocol`` command of the client.
  By default, this activates a protocol defined in the ``Constant`` module,
  with some default parameters and using the default activator key
  (also defined in the ``Constant`` module).
  This activator key was added to the client by ``Client.init``.
  You can override all of this.
  For instance, if you don't want the client to know the default activator key,
  use ``Client.create`` instead of ``Client.init``
  (you can use ``Client.import_secret_key`` to import another activator key, for instance).
  Or, if you want to change the protocol, the fitness or the parameter file,
  you can use the ``?protocol``, ``?fitness`` and ``?parameter_file`` optional
  arguments of ``Client.activate_protocol``.

- Then, we log a message using ``Log.info``.
  This message is not visible with the default verbosity, but you can
  see it by running ``main.exe`` with the ``--info`` option (or ``--verbose``).

- Then, we repeat ``Client.bake_for`` 10 times, to bake 10 blocks.

- Then, we wait for the level of the node to be at least 11 (the activation block
  plus the 10 blocks that we baked). There is an internal listener for node events
  that in particular receives level updates, and the ``Level_at_least 11`` event
  triggers as soon as the level reaches 11. If you start listening to this event
  and the level is already 11 or greater, ``Node.wait_for_event_or_fail``
  triggers immediately. (Note: the ``_or_fail`` part means that if the node
  stops before it reaches level 11, the test will fail.)

- Finally, we read the identity of the node by listening to the ``Read_identity``
  event, which triggers as soon as the node sends the event stating that it read
  the identity file. In fact, this event was probably received much sooner, but
  the internal event listener of Tezt stores the identity in case you try to listen
  to the event later, just like the level.

- We check that the identity is not empty, and if it is we call ``Test.fail``.
  This causes the test to terminate immediately with an error.
  Note that it is not the only cause of failure for this test:
  we already saw that ``Node.wait_for_event_or_fail`` can cause a test failure,
  and if anything goes wrong (failing to initialize the node or the client,
  failing to activate the protocol...) ``Test.fail`` is called automatically as well.

- After the test succeeds or fails, ``Test.run`` cleans up everything.
  It terminates all running processes by sending ``SIGTERM``.
  It waits for them with ``waitpid`` to avoid zombie processes.
  And it removes all temporary files, in particular the data directory of the node
  and the base directory of the client.

- We run this test three times, once per history mode: ``archive``, ``full`` and ``rolling``.
  Note that we added the history mode as a tag to ``Test.run``, so if we want
  to run only the test for history mode ``full``, for instance,
  we can simply run ``dune exec tezt/tests/main.exe -- basic full``.
  You can see our list of basic tests and their tags
  with ``dune exec tezt/tests/main.exe -- basic --list``.
