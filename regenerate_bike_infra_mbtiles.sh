#!/bin/bash
set -e

# https://stackoverflow.com/a/24112741/4490927
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

cd mbtiles_scripts
bash generate_poland_bike_infra_mbtiles.sh

echo "replacing old mbtiles with new"
cd ..
rm -f data/bike_infra.mbtiles
mv data/bike_infra.tmp.mbtiles data/bike_infra.mbtiles

echo "restarting mbtiles_poland_go_server service"
# full path to `service` is required. To find path run `which service`.
/usr/sbin/service mbtiles_poland_go_server restart
