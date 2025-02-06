FROM node:21-alpine AS base

RUN apk add --no-cache libc6-compat

WORKDIR /usr/app

ENV NEXT_TELEMETRY_DISABLED=1

RUN corepack enable


FROM base AS builder

WORKDIR /usr/app

COPY ./ ./

COPY ./scripts/build.env .env

RUN apk add --no-cache openssl
RUN pnpm i --ignore-scripts
RUN pnpm dlx prisma generate

RUN pnpm run build

RUN rm -r .next/cache


FROM base AS runner

WORKDIR /usr/app

COPY ./scripts/entrypoint.sh ./entrypoint.sh
COPY ./prisma ./prisma

COPY --from=builder /usr/app/.next/standalone/ ./
COPY --from=builder /usr/app/.next/static/ ./.next/static/
COPY --from=builder /usr/app/public/ ./public

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1


EXPOSE 3000
ENV HOSTNAME="0.0.0.0"
ENV PORT=3000
ENTRYPOINT ["/bin/sh", "/usr/app/entrypoint.sh"]