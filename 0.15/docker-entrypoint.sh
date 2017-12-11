#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for bgoldd"

  set -- bgoldd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "bgoldd" ]; then
  mkdir -p "$BITCOIN_GOLD_DATA"
  chmod 700 "$BITCOIN_GOLD_DATA"
  chown -R bitcoingold "$BITCOIN_GOLD_DATA"

  echo "$0: setting data directory to $BITCOIN_GOLD_DATA"

  set -- "$@" -datadir="$BITCOIN_GOLD_DATA"
fi

if [ "$1" = "bgoldd" ] || [ "$1" = "bgold-cli" ] || [ "$1" = "bitcoin-tx" ]; then
  echo
  exec gosu bitcoingold "$@"
fi

echo
exec "$@"
