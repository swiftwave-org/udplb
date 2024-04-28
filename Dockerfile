# build stage
FROM --platform=$BUILDPLATFORM golang:1.21.6-bookworm AS build-env
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

RUN echo "Building for ${TARGETOS} ${TARGETARCH}"
RUN echo "Building for ${BUILDPLATFORM}"
RUN echo "Building for ${TARGETPLATFORM}"
WORKDIR /src
COPY . .
RUN echo "Building for ${TARGETOS} ${TARGETARCH}"
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=7 go build -ldflags="-w -s" -o goapp .

# final stage
FROM --platform=$TARGETPLATFORM debian:bookworm
RUN mkdir /app
RUN mkdir /data
WORKDIR /app
COPY --from=build-env /src/goapp /app/goapp
RUN chmod +x /app/goapp
RUN apt-get update -y && apt-get install -y ca-certificates
ENTRYPOINT /app/goapp