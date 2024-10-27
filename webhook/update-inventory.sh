#!/usr/bin/env bash

/usr/bin/docker compose \
  -f /home/alfred/puppet-inventory/local-testing/compose.yaml \
  --profile puppet exec puppet bash \
  -c /etc/puppetlabs/scripts/update-inventory.sh