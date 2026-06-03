#!/bin/sh
set -e

# Arranca cron en background para logrotate
cron

# Cede el control a nginx en foreground
exec "$@"
