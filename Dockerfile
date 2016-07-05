FROM ubuntu:16.04

MAINTAINER antespi@gmail.com

EXPOSE 25

ENV HOST=localhost \
    DOMAIN=localdomain \
    MAILNAME=localdomain \
    MAIL_RELAY_HOST='' \
    MAIL_RELAY_PORT='' \
    MAIL_RELAY_USER='' \
    MAIL_RELAY_PASS='' \
    MAIL_VIRTUAL_FORCE_TO='' \
    MAIL_VIRTUAL_ADDRESSES='' \
    MAIL_VIRTUAL_DEFAULT='' \
    MAIL_CANONICAL_DOMAINS='' \
    MAIL_NON_CANONICAL_PREFIX='' \
    MAIL_NON_CANONICAL_DEFAULT=''

RUN apt-get update && \
    apt-get upgrade -y && \
    echo "postfix postfix/mailname string $MAILNAME" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections && \
    apt-get install -y postfix rsyslog && \
    apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y

ADD postfix /etc/postfix
ADD entrypoint sendmail_test /usr/local/bin/

RUN chmod a+rx /usr/local/bin/* && \
    /usr/sbin/postconf -e smtp_tls_security_level=may && \
    /usr/sbin/postconf -e smtp_sasl_auth_enable=yes && \
    /usr/sbin/postconf -e smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd && \
    /usr/sbin/postconf -e smtp_sasl_security_options=noanonymous && \
    /usr/sbin/postconf -e myhostname=$HOST && \
    /usr/sbin/postconf -e mydomain=$DOMAIN && \
    /usr/sbin/postconf -e mydestination=localhost && \
    /usr/sbin/postconf -e mynetworks='127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128' && \
    /usr/sbin/postconf -e inet_interfaces=loopback-only && \
    /usr/sbin/postconf -e smtp_helo_name=\$myhostname.\$mydomain && \
    /usr/sbin/postconf -e virtual_maps='hash:/etc/postfix/virtual, regexp:/etc/postfix/virtual_regexp' && \
    /usr/sbin/postconf -e sender_canonical_maps=regexp:/etc/postfix/sender_canonical_regexp && \
    /usr/sbin/postmap /etc/postfix/sasl_passwd && \
    /usr/sbin/postmap /etc/postfix/virtual_regexp && \
    /usr/sbin/postmap /etc/postfix/virtual && \
    /usr/sbin/postmap /etc/postfix/sender_canonical_regexp

ENTRYPOINT ["/usr/local/bin/entrypoint"]
# CMD ["tail", "-f", "/var/log/syslog"]
CMD ["sleep", "infinity"]
# CMD ["bash"]
