# build stage
FROM --platform=$BUILDPLATFORM golang:1.21.6-bookworm AS build-env
ENV CGO_ENABLED=0
WORKDIR /src
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build go build -o goapp .

# final stage
FROM --platform=$BUILDPLATFORM debian:bookworm
RUN mkdir /app
RUN mkdir /data
WORKDIR /app
COPY --from=build-env /src/goapp /app/goapp
RUN chmod +x /app/goapp
RUN apt-get update -y && apt-get install -y ca-certificates
ENTRYPOINT /app/goapp