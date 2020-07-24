# tileserver

tileserver is a small, but efficient, Sinatra-based server for Mapbox Vector
Tiles-compatible servers. It serves the tiles directly from mbtiles-formatted 
SQLite3 database, without any preprocessing.

# Runtime environment

tileserver should be started as any other Rack-based application, and should be
compatible with any Rack-compatible host server. However, it also requires a
path to the tile database to be passed in TILESERVER_DATABASE environment
variable. If that variable is missing, it will use "tiles.mbtiles" in the
current directory by default.

# Licensing

tiltserver is licensed under the terms of the MIT license (see LICENSE).
