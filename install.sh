#!/bin/bash

# Atualiza o Ubuntu
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Cria a pasta docker na raiz
if [ ! -d "/docker" ]; then
  mkdir /docker
fi

# Instala o Docker e Docker-Compose
sudo apt install docker.io docker-compose -y

# Acessa a pasta docker
cd /docker

copiar arquivo
if [ -f ~/.env ]; then
  env_file_path=~/.env
elif [ -f /mediaserver2/.env ]; then
  env_file_path=/mediaserver2/.env
else
  echo "Arquivo .env não encontrado"
  exit 1
fi

sudo cp $env_file_path /docker/.env

# Cria o arquivo docker-compose.yml
sudo touch docker-compose.yml

# Escreve a configuração do arquivo docker-compose.yml
cat << EOF | sudo tee docker-compose.yml

version: "3.9"
services:
######MEDIA#####
#Jellyfin - Media server
  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
#      - JELLYFIN_PublishedServerUrl=192.168.0.5 #optional
    volumes:
      - ${DOCKER_APPDATA_PATH}jellyfin:/config
      - ${DATA_PATH}:/data
    ports:
      - 8096:8096
      - 8920:8920 #optional
      - 7359:7359/udp #optional
      - 1900:1900/udp #optional
    restart: unless-stopped
#Plex - Media server
  plex:
    image: lscr.io/linuxserver/plex:latest
    container_name: plex
    network_mode: host
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
      - VERSION=docker
#      - PLEX_CLAIM= #optional
    volumes:
      - ${DOCKER_APPDATA_PATH}plex:/config
      - ${DATA_PATH}:/data
    restart: unless-stopped
#Xteve - IPTV distibutor
  xteve:
    image: alturismo/xteve
    container_name: xteve
    hostname: xteve
    restart: unless-stopped
    networks:
      - default
    ports:
      - "34400:34400"
      - "1901:1900" #1900 used by Plex
    environment:
      TZ: ${TZ}
    volumes:
      - ${DOCKER_APPDATA_PATH}xteve:/config:rw
      - /dev/shm:/tmp/xteve
#Tvheadend
  tvheadend:
    image: lscr.io/linuxserver/tvheadend:latest
    container_name: tvheadend
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
      - RUN_OPTS= #optional
    volumes:
      - ${DOCKER_APPDATA_PATH}:/config
      - ${DOCKER_APPDATA_PATH}recordings:/recordings
    ports:
      - 9981:9981
      - 9982:9982
    devices:
      - /dev/dri:/dev/dri #optional
      - /dev/dvb:/dev/dvb #optional
    restart: unless-stopped
#Sonarr
  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
    volumes:
      - ${DOCKER_APPDATA_PATH}sonarr:/config
      - ${DATA_PATH}:/tv #optional
      - ${DATA_PATH}/downloads:/downloads #optional
    ports:
      - 8989:8989
    restart: unless-stopped
#Radarr
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
    volumes:
      - ${DOCKER_APPDATA_PATH}/radarr:/config
      - ${DATA_PATH}:/movies #optional
      - ${DATA_PATH}/downloads:/downloads #optional
    ports:
      - 7878:7878
    restart: unless-stopped
#Qbitorrent
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
      - WEBUI_PORT=8080
    volumes:
      - ${DOCKER_APPDATA_PATH}qbittorrent/config:/config
      - ${DATA_PATH}/downloads:/downloads
    ports:
      - 8081:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped
#Tautulli
  tautulli:
    image: lscr.io/linuxserver/tautulli:latest
    container_name: tautulli
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
    volumes:
      - ${DOCKER_APPDATA_PATH}tautulli:/config
    ports:
      - 8181:8181
    restart: unless-stopped
#Ombi
  ombi:
    image: lscr.io/linuxserver/ombi:latest
    container_name: ombi
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
      - BASE_URL=/ombi #optional
    volumes:
      - ${DOCKER_APPDATA_PATH}ombi:/config
    ports:
      - 3579:3579
    restart: unless-stopped
#Jackett
  jackett:
    image: lscr.io/linuxserver/jackett:latest
    container_name: jackett
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
      - AUTO_UPDATE=true #optional
      - RUN_OPTS= #optional
    volumes:
      - ${DOCKER_APPDATA_PATH}jacket:/config
      - ${DATA_PATH}/downloads:/downloads
    ports:
      - 9117:9117
    restart: unless-stopped
#Prowlarr
  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
    volumes:
      - ${DATA_PATH}prowlarr:/config
    ports:
      - 9696:9696
    restart: unless-stopped
#Heimdall
  heimdall:
    image: lscr.io/linuxserver/heimdall:latest
    container_name: heimdall
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
    volumes:
      - ${DOCKER_APPDATA_PATH}heimdall:/config
    ports:
      - 8080:80
      - 8443:443
    restart: unless-stopped
#NGINX
  nginx:
    image: lscr.io/linuxserver/nginx:latest
    container_name: nginx
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
    volumes:
      - ${DOCKER_APPDATA_PATH}nginx:/config
    ports:
      - 80:80
      - 443:443
    restart: unless-stopped
#Syncthing
  syncthing:
    image: lscr.io/linuxserver/syncthing:latest
    container_name: syncthing
    hostname: syncthing #optional
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
    volumes:
      - ${DOCKER_APPDATA_PATH}syncthing:/config
      - ${DATA_PATH}/data1:/data1
      - ${DATA_PATH}/data2:/data2
    ports:
      - 8384:8384
      - 22000:22000/tcp
      - 22000:22000/udp
      - 21027:21027/udp
    restart: unless-stopped
#filebrowser
  filebrowser:
    container_name: filebrowser
    image: linuxserver/filebrowser:arm32v7-latest
    ports:
      - "8081:80"
    volumes:
      - ${DATA_PATH}:/srv
      - ${DOCKER_APPDATA_PATH}filebrowser:/config
    restart: always
#netdata
  netdata:
    container_name: netdata
    image: netdata/netdata:arm32v7-latest
    ports:
      - "19999:19999"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    restart: always
#jdownloader
  jdownloader:
    container_name: jdownloader
    image: jlesage/jdownloader:armhf-1.0.2
    ports:
      - "5800:5800"
      - "3129:3129"
    volumes:
      - ${DOCKER_APPDATA_PATH}jdownload:/config:rw
      - ${DATA_PATH}/downloads:/output:rw
    restart: always
#wireguard
  wireguard:
    image: lscr.io/linuxserver/wireguard:latest
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE #optional
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${DOCKER_TIME_ZONE}
      - SERVERURL=wireguard.domain.com #optional
      - SERVERPORT=51820 #optional
      - PEERS=1 #optional
      - PEERDNS=auto #optional
      - INTERNAL_SUBNET=10.13.13.0 #optional
      - ALLOWEDIPS=0.0.0.0/0 #optional
      - PERSISTENTKEEPALIVE_PEERS= #optional
      - LOG_CONFS=true #optional
    volumes:
      - ${DOCKER_APPDATA_PATH}wireguard:/config
      - /lib/modules:/lib/modules #optional
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
EOF    

# Inicia os containers
sudo docker-compose up -d
echo "Todas as etapas foram concluídas com sucesso!"
