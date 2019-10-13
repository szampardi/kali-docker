FROM    nexus166/kali

RUN     export DEBIAN_FRONTEND=noninteractive; \
        echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" | tee /etc/apt/sources.list; \
        echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" | tee -a /etc/apt/sources.list; \
        apt-get update; \
        apt-get dist-upgrade -y; \
        apt-get clean; \
        apt-get autoclean; \
        rm -fr /tmp/* /var/lib/apt/* ~/.cache

CMD     ["/bin/bash"]
