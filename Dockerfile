FROM ubuntu:24.04 AS base
WORKDIR /server

RUN dpkg --add-architecture i386 && \
    apt-get clean && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libstdc++6:i386 \
    curl \
    wget \
    tar \
    jq

FROM base AS download_openmp
WORKDIR /server
ENV OPENMP_FILE_NAME=open.mp-linux-x86.tar.gz
ENV OPENMP_ARTIFACT_URL="https://api.github.com/repos/openmultiplayer/open.mp/releases/latest"

RUN curl -s $OPENMP_ARTIFACT_URL \
    | jq -r ".assets[] | select(.name==\"$OPENMP_FILE_NAME\").browser_download_url" \
    | wget -qi - && \
    tar -xzf $OPENMP_FILE_NAME && \
    rm $OPENMP_FILE_NAME && \
    mv Server/* . && \
    rmdir Server

FROM base AS final
WORKDIR /server
COPY --from=download_openmp /server/ .
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /server/omp-server && chmod +x /entrypoint.sh

EXPOSE 7777/udp
ENTRYPOINT ["/entrypoint.sh"]
