Reading mbtiles metadata:

```bash
sqlite3 poland-bicycle-infra.mbtiles
```

```SQL
select * from metadata where name is not 'json';
```

## Building

Building for ubuntu from mac

```bahs
# https://github.com/mattn/go-sqlite3#cross-compiling-from-mac-osx
brew install FiloSottile/musl-cross/musl-cross
```

```bash
CC=x86_64-linux-musl-gcc CXX=x86_64-linux-musl-g++ GOARCH=amd64 GOOS=linux CGO_ENABLED=1 go build -ldflags "-linkmode external -extldflags -static"
```

## Systemd

Copy `mbtiles_poland_go_server.service` to `/lib/systemd/system`

Start service

```bash
sudo service mbtiles_server_go start
```

Enable service to run on system boot

```bash
sudo systemctl enable mbtiles_server_go
```

Getting logs

```bash
sudo journalctl -u mbtiles_poland_go_server.service -f
```

## Nginx

```bash
 sudo vim /etc/nginx/sites-enabled/default
 ```

```nginx
 location ^~ /mbtiles/ {
  set $unknown_domain 1;

  if ($http_referer ~* "velomapa.pl") {
    set $unknown_domain 0;
  }

  if ($http_referer ~* "myveloway.com") {
    set $unknown_domain 0;
  }

  if ($unknown_domain) {
    add_header Cache-Control 'no-store, no-cache';
    return 404;
  }

  proxy_set_header X-Real-IP         $remote_addr;
  proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header X-Forwarded-Host  $host;
  proxy_set_header X-Forwarded-Port  $server_port;
  proxy_set_header Host              $host;

  #proxy_cache tilecache;
  proxy_pass http://127.0.0.1:6060;
}
```

```
sudo systemctl restart nginx
```
