FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    jq \
    python3 \
    tzdata

ENV \
    DEBEZIUM_URL=http://hi-event-dw-pipeline-staging.hifpt.svc.cluster.local:8083 \
    CURL_INSECURE=false

COPY scripts/.healthzc /app/scripts/.healthzc

RUN chmod +x /app/scripts/.healthzc

ENV HEALTHCHECK_INTERVAL=30

# Cron does not support 15-second scheduling, so use a simple loop runner.
CMD ["bash", "-lc", "while true; do if [ -f /app/.env ]; then set -a; source /app/.env; set +a; fi; source /app/scripts/.healthzc; sleep \"${HEALTHCHECK_INTERVAL}\"; done"]
