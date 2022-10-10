# Mbtiles Poland

Repo containing scripts for generating different mbtiles of Poland's data and Go server.

## Crontab

```bash
sudo crontab -e
```

Run command every night at 02:00 UTC

```
0 2 * * * /home/caspg/mbtiles-poland/regenerate_bike_infra_mbtiles.sh
```
