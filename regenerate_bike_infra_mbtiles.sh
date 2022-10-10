#!/bin/bash

# https://stackoverflow.com/a/24112741/4490927
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

cd mbtiles_scripts
bash generate_poland_bike_infra_mbtiles.sh

cd ..
rm bike_infra.mbtiles
mv bike_infra.tmp.mbtiles bike_infra.mbtiles

# full path to `service` is required. To find path run `which service`.
/usr/sbin/service mbtiles_poland_go_server restart
