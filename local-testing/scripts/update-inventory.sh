#!/usr/bin/env bash

/usr/local/bin/r10k deploy environment -m

curl -i --cert $(puppet config print hostcert) \
  --key $(puppet config print hostprivkey) \
  --cacert $(puppet config print cacert) \
  -X DELETE \
  https://$(puppet config print server):8140/puppet-admin-api/v1/environment-cache
