# build stage
FROM --platform=$BUILDPLATFORM golang:1.21.6-bookworm AS build-env
ENV CGO_ENABLED=0
# Set GOARCH based on the build platform
RUN export GOARCH=$(echo "$BUILDPLATFORM" | cut -d'/' -f2)
ENV GOOS="linux"
ENV GOARCH=$GOARCH
WORKDIR /src
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build go build -o goapp -ldflags '-extldflags "-static"' .

# final stage
FROM --platform=$BUILDPLATFORM ubuntu:22.04
RUN mkdir /app
RUN mkdir /data
WORKDIR /app
COPY --from=build-env /src/goapp /app/goapp
RUN apt-get update && apt-get install -y ca-certificates
ENTRYPOINT /app/goapp