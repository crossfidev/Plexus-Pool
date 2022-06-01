******************************
Building documentation locally
******************************

The documentation is available online at `mineplex.gitlab.io <http://mineplex.gitlab.io/>`_,
always up to date with master on `GitLab <https://gitlab.com/mineplex/mineplex>`_.

Building instructions
---------------------

To build the documentation, you can use the main Makefile target ``doc-html``

.. code-block:: bash

    # in the project root directory
    make doc-html

The documentation is built by Sphinx, and uses the Read The Docs theme.

On a debian system, you can install the needed dependencies with:

.. code-block:: bash

    sudo apt install \
      python3-recommonmark \
      python3-sphinx \
      python3-sphinx-rtd-theme

If you prefer to use a specific python environment to build the documentation, create a virtualenv with a python3 interpreter and install these PIP packages:

.. code-block:: bash

   pip install sphinx sphinx-rtd-theme recommonmark

The HTML pages will be available in `docs/_build`.


Sphinx extensions
-----------------

Some ad-hoc reference kinds are supported.

- ``:package-src:`name``` or ``:package-src:`text<name>``` points
  to the gitlab source tree viewer where the `.opam` for the package
  is located
- ``:package:`name``` or ``:package:`text<name>``` now points
  either to the `odoc` page, or if it doesn't exist, to the gitlab
  source tree viewer
- ``:package-name:`name``` or ``:package-name:`text<name>``` just
  displays the package name (no link), checking that the package
  exists
- ``:src:`/path/to/file/or/dir``` or
  ``:src:`text</path/to/file/or/dir>``` points to the gitlab source
  tree viewer
- ``:opam:`package``` or ``:opam:`text<package>``` points to the
  package page on ``opam.ocaml.org``, version number is supported
  (``package.version``)

OCaml documentation
-------------------

Odoc is used for OCaml API generation, that you can install with:

.. code-block:: bash

    opam install odoc

mineplex generates the API documentation for all libraries in HTML format.  The
generated HTML pages in ``_build/<context>/_doc``. It creates one sub-directory
per public library and generates an ``index.html`` file in each sub-directory.

The documentation is not installed on the system by mineplex. It is meant to be
read locally while developing and then published on the www when releasing
packages.
