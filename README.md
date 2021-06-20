# Dump database(s) via Docker
This docker image helps you to dump mysql databases.

Build Image:

    docker build --tag database-dumper:latest .

Call it like this:

    docker run --rm database-dumper:latest

You can pass credentials as param or as environment variable

For more details call:

    docker run --rm database-dumper:latest --help


PS: see docker-compose file for development od experimental
