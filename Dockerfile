FROM ubuntu:24.04 AS base
WORKDIR /server

RUN dpkg --add-architecture i386 && \
    apt-get clean && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libstdc++6:i386 build-essential \
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


FROM base AS download_configuration
WORKDIR /server
ENV ZENID_CONFIG_FILE_NAME=config.zip
ENV ZENID_RESOURCES_URL="https://api.github.com/repos/zenidro/config/releases/latest"
RUN curl -s $ZENID_RESOURCES_URL \
    | jq -r ".assets[] | select(.name==\"$ZENID_CONFIG_FILE_NAME\").browser_download_url" \
    | wget -qi - && \
    unzip $ZENID_CONFIG_FILE_NAME && \
    rm $ZENID_CONFIG_FILE_NAME

FROM base AS final
WORKDIR /server
COPY --from=download_openmp /server/ .
COPY --from=download_configuration /server/ .
COPY entrypoint.sh /entrypoint.sh
RUN /compiler/pawncc /gamemodes/main.pwn -Dgamemodes "-;+" "--(+" "-d3"
RUN rm compiler

RUN chmod +x /server/omp-server && chmod +x /entrypoint.sh

EXPOSE 7777/udp
ENTRYPOINT ["/entrypoint.sh"]
