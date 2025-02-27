# Use BuildKit for tmpfs
# syntax=docker/dockerfile:1.4

# First Stage: Build cURL in RAM
FROM ubuntu:22.04 AS builder1

RUN --mount=type=tmpfs,target=/tmp \
    apt-get update && \
    apt-get install -y wget curl build-essential cmake libssl-dev && \
    cd /tmp && \
    wget https://github.com/curl/curl/releases/download/curl-8_4_0/curl-8.4.0.tar.gz && \
    tar -xzf curl-8.4.0.tar.gz && \
    cd curl-8.4.0 && \
    ./configure --with-openssl && \
    make -j$(nproc) && \
    find /tmp/curl-8.4.0 -type f -name 'curl'  # Debugging: Find built binary

# Second Stage: Build FFMPEG in RAM
FROM ubuntu:22.04 AS builder2

RUN --mount=type=tmpfs,target=/tmp \
    apt-get update && \
    apt-get install -y wget build-essential yasm pkg-config libssl-dev libx264-dev && \
    cd /tmp && \
    wget https://ffmpeg.org/releases/ffmpeg-6.0.tar.gz && \
    tar -xzf ffmpeg-6.0.tar.gz && \
    cd ffmpeg-6.0 && \
    ./configure --enable-gpl --enable-libx264 --enable-libx265 && \
    make -j$(nproc) && \
    find /tmp/ffmpeg-6.0 -type f -name 'ffmpeg'  # Debugging: Find built binary

