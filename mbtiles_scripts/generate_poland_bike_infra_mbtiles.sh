#!/bin/bash
set -e

echo "Starting generating Poland bike infra mbtiles"
echo $(date +'%Y-%m-%d %H:%M %Z')

# https://stackoverflow.com/a/24112741/4490927
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

echo "clean tmp directory"
rm -rf ../tmp
mkdir ../tmp

# https://download.geofabrik.de/europe/poland.html

echo "download poland-latest.osm.pbf"
curl https://download.geofabrik.de/europe/poland-latest.osm.pbf -o ../tmp/input.osm.pbf
# curl https://download.geofabrik.de/europe/poland/pomorskie-latest.osm.pbf -o ../tmp/input.osm.pbf

echo "log debug data"
osmium fileinfo ../tmp/input.osm.pbf

echo "run tags-filter"
osmium tags-filter ../tmp/input.osm.pbf \
  w/highway=cycleway \
  w/bicycle=designated \
  w/cycleway=lane \
  w/cycleway=opposite_lane \
  w/cycleway=track \
  w/cycleway:right=lane \
  w/cycleway:left=lane \
  w/cycleway:both=lane \
  w/cycleway:right=track \
  w/cycleway:left=track \
  w/cycleway:both=track \
  w/bicycle=yes \
  w/highway=footway \
  w/oneway:bicycle=no \
  -o ../tmp/out.osm.pbf

echo "run osmconvert"
osmconvert ../tmp/out.osm.pbf -o=../tmp/out.o5m

echo "run osmfilter"
osmfilter ../tmp/out.o5m \
  --ignore-dependencies \
  --drop-ways="mtb:scale= or route=mtb or informal=yes or highway=proposed or highway=construction" \
  --keep-ways="highway=cycleway or ( oneway:bicycle=no and oneway=yes ) or ( oneway:bicycle=no and oneway=cycleway ) or ( bicycle=yes and highway=footway ) or ( bicycle=permissive and highway=footway ) or ( foot=designated and bicycle=designated and segregated=yes ) or ( foot=designated and bicycle=designated and segregated=no ) or cycleway=track or cycleway:*=track or cycleway:*=lane or cycleway=lane or cycleway:*=opposite_lane or cycleway=opposite_lane" \
  >../tmp/out.osm

echo "run ogr2ogr"
OSM_CONFIG_FILE=./config/osmconf_bike_infra.ini ogr2ogr -f GeoJSON ../tmp/out.geojson ../tmp/out.osm lines

echo "run tippecanoe"
# `-z14`: Only generate zoom levels 0 through 14
# `-l`: layer name
# To find path run `which tippecanoe`
/usr/local/bin/tippecanoe --force -z14 -o ../data/bike_infra.tmp.mbtiles -l default --drop-fraction-as-needed ../tmp/out.geojson
