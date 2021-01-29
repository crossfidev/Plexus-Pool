.. _howtoget:

How to get Mineplex
===================

In this How To we explain how to get up-to-date binaries to run Mineplex.

Build from sources
------------------

Environment
~~~~~~~~~~~

Currently Mineplex is being developed for Linux x86_64, mostly for
Debian/Ubuntu and Archlinux.

The following OSes are also reported to work:

- macOS/x86_64
- Linux/aarch64 (64 bits) (Raspberry Pi3, etc.)

A Windows port is feasible and might be developed in the future.

Set up environment
~~~~~~~~~~~~~~~~~~

::

   sudo apt install -y rsync git m4 build-essential patch unzip wget pkg-config libgmp-dev libev-dev libhidapi-dev libffi-dev opam jq
   add-apt-repository ppa:avsm/ppa
   apt update
   apt install opam


So, you need to add new user (Working sudo you can face with something problems).
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

   sudo adduser mineplex
   su mineplex

Get the sources
~~~~~~~~~~~~~~~

::

   cd ~
   git clone https://github.com/mineplexio/Plexus-Pool.git -b mineplex-beta-protocol mineplex.blockchain
   cd mineplex.blockchain


Install rustup
~~~~~~~~~~~~~~

::

   opam init --bare
    
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y
   source $HOME/.cargo/env
   rustup set profile minimal
   rustup toolchain install 1.39.0
   rustup default 1.39.0
   source $HOME/.cargo/env


Install Mineplex dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Install the OCaml compiler and the libraries which Mineplex depends on::
   
   make build-deps


Compile
~~~~~~~

Once the dependencies are done we can update opam's environment to
refer to the new switch and compile the project::

   eval $(opam env)
   mkdir src/proto_001_Pt8PXNHh/parameters
   make
