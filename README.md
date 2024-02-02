# Mbtiles Poland

Repo containing scripts for generating different mbtiles of Poland's data and Go server.

## Crontab

```bash
sudo crontab -e
```

Run command every night at 02:00 UTC

```
0 2 * * * bash /home/<USER_NAME>/mbtiles-poland/regenerate_bike_infra_mbtiles.sh > /home/<USER_NAME>/mbtiles-poland/logs/regenerate_bike_infra_mbtiles.log 2>&1
```

cron logs

```bash
sudo grep CRON /var/log/syslog
```

## Expose update timestamp in nginx

```nginx
location /mbtiles/infra/updated-at.txt {
  add_header Access-Control-Allow-Origin *;
  add_header Cache-Control 'no-store, no-cache';

  alias /home/caspg/mbtiles-poland/public/infra_update_date.txt;
}

```

```bash
sudo systemctl restart nginx
```
