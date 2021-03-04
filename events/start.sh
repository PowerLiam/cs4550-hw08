#!/bin/bash

export SECRET_KEY_BASE=insecure
export MIX_ENV=prod
export PORT=4793

CFGD=$(readlink -f ~/.config/events)

if [ ! -e "$CFGD/base" ]; then
    echo "Need to deploy first"
    exit 1
fi

SECRET_KEY_BASE=$(cat "$CFGD/base")
export SECRET_KEY_BASE

echo "Stopping old copy of app, if any..."

_build/prod/rel/events/bin/events stop || true

echo "Starting app..."

_build/prod/rel/events/bin/events start
