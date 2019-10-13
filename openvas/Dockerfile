FROM	nexus166/kali
SHELL	["/bin/bash", "-exvo", "pipefail", "-c"]

# install openvas and dependencies
RUN	export DEBIAN_FRONTEND=noninteractive; \
	apt-get update; \
	apt-get dist-upgrade -y; \
	apt-get install -y --no-install-recommends \
		alien arachni bzip2 curl lsof net-tools nmap nsis openssh-client openvas procps psmisc rpm rsync sqlite3 xsltproc; \
	rm -fr /var/lib/apt/* /tmp/* ~/.cache; \
	mkdir -vp /var/run/redis-openvas; \
	sed -i 's/^port 0/port 6379/g;s/^bind 127.0.0.1 ::1/bind 127.0.0.1/g' /etc/redis/redis-openvas.conf; \
	sed -i 's/MANAGER_ADDRESS=127.0.0.1/MANAGER_ADDRESS=0.0.0.0/g' /etc/default/openvas-manager; \
	sed -i 's/GSA_ADDRESS=127.0.0.1/GSA_ADDRESS=0.0.0.0/g;s/MANAGER_ADDRESS=127.0.0.1/MANAGER_ADDRESS=0.0.0.0/g' /etc/default/greenbone-security-assistant

# selftest
RUN	redis-server /etc/redis/redis-openvas.conf; \
	until [[ "$(redis-cli ping)" == "PONG" ]]; do echo "Waiting for redis to be ready.."; sleep 5; done; \
	for _svc in openvas-scanner openvas-manager; do "/etc/init.d/$_svc" restart; done; \
	/usr/sbin/greenbone-nvt-sync --selftest --verbose; \
	/usr/sbin/greenbone-scapdata-sync --selftest --verbose; \
	/usr/sbin/greenbone-certdata-sync --selftest --verbose; \
	for _svc in openvas-scanner openvas-manager; do "/etc/init.d/$_svc" stop; done; \
	/etc/init.d/redis-server stop

# entrypoint
RUN	{ \
		printf '#!/usr/bin/env bash\nset -x;\nredis-server /etc/redis/redis-openvas.conf;\n'; \
		printf 'until [[ "$(redis-cli ping)" == "PONG" ]]; do echo "Waiting for redis to be ready.."; sleep 5; done;\n'; \
		printf '[[ ! -z "$ALLOW_HEADER_HOST" ]] && sed -i "/^DAEMON=.*/a DAEMONOPTS=\"\$DAEMONOPTS --allow-header-host $ALLOW_HEADER_HOST\"" /etc/init.d/greenbone-security-assistant;\n'; \
		printf '/usr/bin/openvas-setup;\n/etc/init.d/openvas-scanner restart;\n/etc/init.d/openvas-manager restart;\n'; \
		printf 'openvasmd --create-user=admin --role=Admin && openvasmd --user=admin --new-password="$ADMIN_PASS";\n'; \
		printf '/etc/init.d/greenbone-security-assistant restart;\nopenvas-check-setup --v9;\ntail -F /var/log/openvas/*\n'; \
	} | tee /usr/local/bin/entrypoint.sh; \
	chmod -v +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# svc ports
EXPOSE	80 9392
