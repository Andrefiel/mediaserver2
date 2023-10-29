version: "3.9"
services:
######MEDIA#####
#Jellyfin - Media server
  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    environment:
      - PUID=1001
      - PGID=1001
      - TZ=America/Fortaleza
      - JELLYFIN_PublishedServerUrl=192.168.0.5 #optional
    volumes:
      - /docker/appdata/jellyfin:/config
      - /docker/media:/data
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
      - TZ=Etc/UTC
      - VERSION=docker
      - PLEX_CLAIM= #optional
    volumes:
      - /path/to/library:/config
      - /path/to/tvseries:/tv
      - /path/to/movies:/movies
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
      - ${USERDIR}/docker/xteve:/config:rw
      - /dev/shm:/tmp/xteve
#Tvheadend
  tvheadend:
    image: lscr.io/linuxserver/tvheadend:latest
    container_name: tvheadend
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - RUN_OPTS= #optional
    volumes:
      - /path/to/data:/config
      - /path/to/recordings:/recordings
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
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /path/to/data:/config
      - /path/to/tvseries:/tv #optional
      - /path/to/downloadclient-downloads:/downloads #optional
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
      - TZ=Etc/UTC
    volumes:
      - /path/to/data:/config
      - /path/to/movies:/movies #optional
      - /path/to/downloadclient-downloads:/downloads #optional
    ports:
      - 7878:7878
    restart: unless-stopped
#Qbitorrent
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1001
      - PGID=1001
      - TZ=America/Fortaleza
      - WEBUI_PORT=8080
    volumes:
      - /docker/appdata/qbittorrent/config:/config
      - /docker/media/downloads:/downloads
    ports:
      - 8080:8080
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
      - TZ=Etc/UTC
    volumes:
      - <path to data>:/config
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
      - TZ=Etc/UTC
      - BASE_URL=/ombi #optional
    volumes:
      - /path/to/appdata/config:/config
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
      - TZ=Etc/UTC
      - AUTO_UPDATE=true #optional
      - RUN_OPTS= #optional
    volumes:
      - /path/to/data:/config
      - /path/to/blackhole:/downloads
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
      - TZ=Etc/UTC
    volumes:
      - /path/to/data:/config
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
      - TZ=Etc/UTC
    volumes:
      - /path/to/appdata/config:/config
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
      - TZ=Etc/UTC
    volumes:
      - </path/to/appdata/config>:/config
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
      - TZ=Etc/UTC
    volumes:
      - /path/to/appdata/config:/config
      - /path/to/data1:/data1
      - /path/to/data2:/data2
    ports:
      - 8384:8384
      - 22000:22000/tcp
      - 22000:22000/udp
      - 21027:21027/udp
    restart: unless-stopped
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
      - TZ=Etc/UTC
      - SERVERURL=wireguard.domain.com #optional
      - SERVERPORT=51820 #optional
      - PEERS=1 #optional
      - PEERDNS=auto #optional
      - INTERNAL_SUBNET=10.13.13.0 #optional
      - ALLOWEDIPS=0.0.0.0/0 #optional
      - PERSISTENTKEEPALIVE_PEERS= #optional
      - LOG_CONFS=true #optional
    volumes:
      - /path/to/appdata/config:/config
      - /lib/modules:/lib/modules #optional
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
