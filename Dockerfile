FROM debian:zlp-10 as base
# Define User and Group
ARG USER=zdeploy
ARG GROUP=zdeploy
ARG UID=2000
ARG GID=2000
ARG HOME=/home/zdeploy

RUN apt-get install tzdata
RUN apt-get update && apt-get upgrade -y && apt-get install -y ca-certificates && apt-get install -y curl

ENV TZ=Asia/Ho_Chi_Minh

# Add User group and install deps
RUN groupadd -g $GID $GROUP && \
useradd -d $HOME -u $UID -s /bin/false --gid $GID $USER && \
mkdir -p $HOME && \
chown -R $GROUP:$USER $HOME && \
    echo $TZ > /etc/timezone
WORKDIR $HOME
USER $USER

# Build server stage
FROM golang:1.16 AS builder
ENV GO111MODULE=on
ARG CACHE_DIR=/tmp
# Set the Current Working Directory inside the container
WORKDIR /cmd
COPY go.mod .
# COPY go.sum .
# Run go mod download
RUN go mod download
COPY . .
# Build Go app
RUN --mount=type=cache,id=cache-go,target=$CACHE_DIR/.cache CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o simpleServer *.go
CMD chmod +x /cmd/entry-point.sh

# Final stage
FROM base
# Copy binary from builder
WORKDIR /cmd
COPY --from=builder /cmd/entryPoint.sh /cmd/entryPoint.sh
COPY --from=builder /cmd/curlApi.sh /cmd/curlApi.sh
COPY --from=builder /cmd/simpleServer /cmd/simpleServer
# Run server command
ENTRYPOINT ["./entryPoint.sh"]
