FROM    debian:bullseye-slim
SHELL	["/bin/bash", "-xeo", "pipefail", "-c"]
RUN     export DEBIAN_FRONTEND=noninteractive; \
	apt-get update; \
	apt-get install -yqq apt-transport-https ca-certificates curl gnupg dirmngr; \
	curl -so- https://archive.kali.org/archive-key.asc | apt-key add -; \
        echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" | tee /etc/apt/sources.list; \
        echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" | tee -a /etc/apt/sources.list; \
        apt-get update; \
        apt-get dist-upgrade -y; \
        apt-get clean; \
        apt-get autoclean; \
        rm -fr /tmp/* /var/lib/apt/* ~/.cache
