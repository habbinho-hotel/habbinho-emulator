# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM eclipse-temurin:25-jdk-noble AS build
WORKDIR /build/Emulator
# Without unzip, mvnw downloads a tarball but still checks the pinned ZIP hash.
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/*
COPY Emulator/ ./
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw -B -ntp package -DskipTests \
    && cp target/Polaris-*-jar-with-dependencies.jar /build/polaris.jar

FROM eclipse-temurin:25-jre-noble
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /data /var/www/gamedata \
    && chown 1000:1000 /app /data
COPY --from=build /build/polaris.jar /app/polaris.jar
COPY ["config example/config.ini.example", "/app/config.ini.example"]
COPY LICENSE /app/LICENSE
COPY --chmod=755 docker/entrypoint.sh /entrypoint.sh

USER 1000:1000
EXPOSE 2096
HEALTHCHECK --interval=15s --timeout=5s --start-period=180s --retries=10 \
    CMD ["curl", "--fail", "--silent", "--max-time", "3", "http://127.0.0.1:2096/api/health"]
ENTRYPOINT ["/entrypoint.sh"]
