.. _howtoupdate:

How to update Mineplex
================

Run this script::

    git pull
    pkill -9 "mineplex*"
    sleep 5
    eval $(opam env)
    make
    nohup ./mineplex-node run --data-dir ~/mineplex-mainnet --rpc-addr 127.0.0.1:8732 --history-mode=archive --connections 15 > ~/node.log &
    sleep 1
    nohup ./mineplex-baker-003-PtWEnWTw -base-dir ~/mineplex-client run with local node ~/mineplex-mainnet baker > ~/baker.log &
    nohup ./mineplex-endorser-003-PtWEnWTw -base-dir ~/mineplex-client run > ~/endorser.log &
    nohup ./mineplex-accuser-003-PtWEnWTw -base-dir ~/mineplex-client run > ~/accuser.log &
    sleep 5
    tail -n 2 ../node.log
    tail -n 2 ../baker.log
    tail -n 2 ../endorser.log
    tail -n 2 ../accuser.log

