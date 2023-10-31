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
sudo usermod -aG docker $USER

# Acessa a pasta docker
cd /docker

copiar arquivo
if [ -f ~/.env ]; then
  env_file_path=~/.env
elif [ -f /tmp/mediaserver2/.env ]; then
  env_file_path=/tmp/mediaserver2/.env
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
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
#      - JELLYFIN_PublishedServerUrl=192.168.0.5 #optional
    volumes:
      - /docker/appdata/jellyfin:/config
      - /docker/media/:/data
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
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
      - VERSION=docker
#      - PLEX_CLAIM= #optional
    volumes:
      - /docker/appdata/plex:/config
      - /docker/media/:/data
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
      - /docker/appdata/xteve:/config:rw
      - /dev/shm:/tmp/xteve
#Tvheadend
  tvheadend:
    image: lscr.io/linuxserver/tvheadend:latest
    container_name: tvheadend
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
      - RUN_OPTS= #optional
    volumes:
      - /docker/appdata/tvheadend:/config
      - /docker/appdata/recordings:/recordings
    ports:
      - 9981:9981
      - 9982:9982
    devices:
      - /dev/dri:/dev/dri #optional
#      - /dev/dvb:/dev/dvb #optional
    restart: unless-stopped
#Sonarr
  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
    volumes:
      - /docker/appdata/sonarr:/config
      - /docker/media/:/tv #optional
      - /docker/media/downloads:/downloads #optional
    ports:
      - 8989:8989
    restart: unless-stopped
#Radarr
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
    volumes:
      - /docker/appdata//radarr:/config
      - /docker/media/:/movies #optional
      - /docker/media/downloads:/downloads #optional
    ports:
      - 7878:7878
    restart: unless-stopped
#Qbitorrent
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
      - WEBUI_PORT=8080
    volumes:
      - /docker/appdata/qbittorrent/config:/config
      - /docker/media/downloads:/downloads
    ports:
      - 8082:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped
#Tautulli
  tautulli:
    image: lscr.io/linuxserver/tautulli:latest
    container_name: tautulli
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
    volumes:
      - /docker/appdata/tautulli:/config
    ports:
      - 8181:8181
    restart: unless-stopped
#Ombi
  ombi:
    image: lscr.io/linuxserver/ombi:latest
    container_name: ombi
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
      - BASE_URL=/ombi #optional
    volumes:
      - /docker/appdata/ombi:/config
    ports:
      - 3579:3579
    restart: unless-stopped
#Jackett
  jackett:
    image: lscr.io/linuxserver/jackett:latest
    container_name: jackett
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
      - AUTO_UPDATE=true #optional
      - RUN_OPTS= #optional
    volumes:
      - /docker/appdata/jacket:/config
      - /docker/media/downloads:/downloads
    ports:
      - 9117:9117
    restart: unless-stopped
#Prowlarr
  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
    volumes:
      - /docker/media/prowlarr:/config
    ports:
      - 9696:9696
    restart: unless-stopped
#Heimdall
  heimdall:
    image: lscr.io/linuxserver/heimdall:latest
    container_name: heimdall
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
    volumes:
      - /docker/appdata/heimdall:/config
    ports:
      - 8080:80
      - 8443:443
    restart: unless-stopped
#NGINX
  nginx:
    image: lscr.io/linuxserver/nginx:latest
    container_name: nginx
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
    volumes:
      - /docker/appdata/nginx:/config
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
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
    volumes:
      - /docker/appdata/syncthing:/config
      - /docker/media/data1:/data1
      - /docker/media/data2:/data2
    ports:
      - 8384:8384
      - 22000:22000/tcp
      - 22000:22000/udp
      - 21027:21027/udp
    restart: unless-stopped
#filebrowser
  filebrowser:
    container_name: filebrowser
    image: filebrowser/filebrowser
    ports:
      - "8081:80"
    volumes:
      - /docker/media/:/srv
      - /docker/appdata/filebrowser:/config
    restart: always
#netdata
  netdata:
    container_name: netdata
    image: netdata/netdata
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
    image: jlesage/jdownloader-2
    ports:
      - "5800:5800"
      - "3129:3129"
    volumes:
      - /docker/appdata/jdownload:/config:rw
      - /docker/media//downloads:/output:rw
    restart: always
#wireguard
  wireguard:
    image: lscr.io/linuxserver/wireguard:latest
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
      - SERVERURL=wireguard.domain.com #optional
      - SERVERPORT=51820 #optional
      - PEERS=1 #optional
      - PEERDNS=auto #optional
      - INTERNAL_SUBNET=10.13.13.0 #optional
      - ALLOWEDIPS=0.0.0.0/0 #optional
      - PERSISTENTKEEPALIVE_PEERS= #optional
      - LOG_CONFS=true #optional
    volumes:
      - /docker/appdata/wireguard:/config
      - /lib/modules:/lib/modules #optional
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
#firefox  
#  firefox:
#    image: lscr.io/linuxserver/firefox:latest
#    container_name: firefox
#    security_opt:
#      - seccomp:unconfined #optional
#    environment:
#      - PUID=1000
#      - PGID=1000
#      - TZ=America/Fortaleza
#    volumes:
#      - /docker/appdata/firefox/config:/config
#    ports:
#      - 3000:3000
#      - 3001:3001
#    shm_size: "1gb"
#    restart: unless-stopped
#Opera
  opera:
    image: lscr.io/linuxserver/opera:latest
    container_name: opera
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Fortaleza
      - OPERA_CLI=https://www.linuxserver.io/ #optional
    volumes:
      - /path/to/config:/config
    ports:
      - 3000:3000
      - 3001:3001
    shm_size: "1gb"
    restart: unless-stopped
EOF    

# Inicia os containers
sudo docker compose -f ~/docker/docker-compose.yml up -d
echo "Todas as etapas foram concluídas com sucesso!"
