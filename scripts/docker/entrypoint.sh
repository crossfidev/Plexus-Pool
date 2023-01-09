#!/bin/sh
set -e

bin_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"

: ${BIN_DIR:="/usr/local/bin"}
: ${DATA_DIR:="/var/run/tezos"}

: ${NODE_HOST:="node"}
: ${NODE_RPC_PORT:="8732"}

: ${PROTOCOL:="unspecified-PROTOCOL-variable"}

node="$BIN_DIR/mineplex-node"
client="$BIN_DIR/mineplex-client"
admin_client="$BIN_DIR/mineplex-admin-client"
baker="$BIN_DIR/mineplex-baker-$PROTOCOL"
endorser="$BIN_DIR/mineplex-endorser-$PROTOCOL"
accuser="$BIN_DIR/mineplex-accuser-$PROTOCOL"
signer="$BIN_DIR/mineplex-signer"

client_dir="$DATA_DIR/client"
node_dir="$DATA_DIR/node"
node_data_dir="$node_dir/data"

. "$bin_dir/entrypoint.inc.sh"

command=${1:-mineplex-node}
shift 1

case $command in
    mineplex-node)
        launch_node "$@"
        ;;
    mineplex-upgrade-storage)
        upgrade_node_storage
        ;;
    mineplex-snapshot-import)
        snapshot_import "$@"
        ;;
    mineplex-baker)
        launch_baker "$@"
        ;;
    mineplex-baker-test)
        launch_baker_test "$@"
        ;;
    mineplex-endorser)
        launch_endorser "$@"
        ;;
    mineplex-endorser-test)
        launch_endorser_test "$@"
        ;;
    mineplex-accuser)
        launch_accuser "$@"
        ;;
    mineplex-accuser-test)
        launch_accuser_test "$@"
        ;;
    mineplex-client)
        configure_client
        exec "$client" "$@"
        ;;
    mineplex-admin-client)
        configure_client
        exec "$admin_client" "$@"
        ;;
    mineplex-signer)
        exec "$signer" "$@"
        ;;
    *)
        cat <<EOF
Available commands:

The following are wrappers around the mineplex binaries.
To call the mineplex binaries directly you must override the
entrypoint using --entrypoint . All binaries are in
$BIN_DIR and the mineplex data in $DATA_DIR

You can specify the network with argument --network, for instance:
  --network carthagenet
(default is mainnet).

Daemons:
- mineplex-node [args]
  Initialize a new identity and run the mineplex node.

- mineplex-baker [keys]
- mineplex-baker-test [keys]
- mineplex-endorser [keys]
- mineplex-endorser-test [keys]

Clients:
- mineplex-client [args]
- mineplex-signer [args]
- mineplex-admin-client

Commands:
  - mineplex-upgrade-storage
  - mineplex-snapshot-import [args]
    Import a snapshot. The snapshot must be available in the file /snapshot
    Using docker run, you can make it available using the command :
       docker run -v <yourfilename>:/snapshot mineplex/mineplex mineplex-snapshot-import
    <yourfilename> must be an absolute path.
EOF
        ;;
esac
