#!/bin/bash

cd mbtiles_scripts
bash generate_poland_bike_infra_mbtiles.sh

cd ..
rm bike_infra.mbtiles
mv bike_infra.tmp.mbtiles bike_infra.mbtiles
service mbtiles_poland_go_server restart
