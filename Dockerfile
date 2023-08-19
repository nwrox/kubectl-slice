FROM golang:1.19-alpine AS build

ARG CGO_ENABLED=0
ARG GH_USER_ARG=
ARG GOARCH=amd64
ARG GOOS=linux
ARG SLICE_VERSION=v1.2.6
ARG LD_FLAGS="-s -w -X main.version="${SLICE_VERSION}" -extldflags -static"

ENV GH_USER="${GH_USER}"

#LABEL org.opencontainers.image.source="https://github.com/${GH_USER}/kubectl-slice"

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . ./

RUN CGO_ENABLED="${CGO_ENABLED}" GOARCH="${GOARCH}" GOOS="${GOOS}" go build -ldflags="${LD_FLAGS}" \
        -o /kubectl-slice \
        -tags netgo \
        -trimpath

#-----------------
FROM busybox:stable

ARG BUILD_DATE

COPY --chmod=0755 --from=build /kubectl-slice /usr/bin

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.description="kubectl-slice container" \
      org.opencontainers.image.source="https://github.com/patrickdappollonio/kubectl-slice" \
      org.opencontainers.image.title="kubectl-slice:latest"

USER 1002:1002

ENTRYPOINT [ "/usr/bin/kubectl-slice" ]
