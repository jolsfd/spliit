#!/bin/bash
set -euxo pipefail

pnpm dlx prisma migrate deploy
exec node /usr/app/server.js