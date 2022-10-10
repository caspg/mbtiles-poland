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

Copy `mbtiles_server_go.service` to `/lib/systemd/system`

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
sudo journalctl -u mbtiles_server_go.service -f
```
