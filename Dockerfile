FROM golang:1.19-alpine AS build

ARG CGO_ENABLED=0
ARG GOARCH=amd64
ARG GOOS=linux
ARG SLICE_VERSION=v1.2.6
ARG LD_FLAGS="-s -w -X main.version="${SLICE_VERSION:-v1.2.6}" -extldflags -static"

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . ./

RUN CGO_ENABLED="${CGO_ENABLED}" GOARCH="${GOARCH}" GOOS="${GOOS}" go build -ldflags="${LD_FLAGS}" \
        -o /kubectl-slice \
        -tags netgo \
        -trimpath

FROM busybox:stable

ARG BUILD_DATE=
ARG GH_REPO=
ARG GH_REPO_DESCRIPTION=
ARG SLICE_VERSION=v1.2.6

COPY --chmod=0755 --from=build /kubectl-slice /usr/bin

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.description="${GH_REPO_DESCRIPTION}" \
      org.opencontainers.image.source="https://github.com/${GH_REPO}" \
      org.opencontainers.image.title="kubectl-slice:latest" \
      org.opencontainers.image.version="${SLICE_VERSION:-v1.2.6}"

USER 1002:1002

ENTRYPOINT [ "/usr/bin/kubectl-slice" ]
