FROM ubuntu:latest

#install the slapd and ldap-utils

RUN echo "slapd slapd/password1 password password" | debconf-set-selections; \
    echo "slapd slapd/password2 password password" | debconf-set-selections; \
    apt-get update && apt-get -y install slapd ldap-utils

#install the fusiondirectory-schema
RUN echo "# fusiondirectory repository" >> /etc/apt/sources.list;\
    echo "deb http://repos.fusiondirectory.org/fusiondirectory-current/debian-jessie jessie main" >> /etc/apt/sources.list;\
    echo "# fusiondirectory extra repository" >> /etc/apt/sources.list;\
    echo "deb http://repos.fusiondirectory.org/fusiondirectory-extra/debian-jessie jessie main" >> /etc/apt/sources.list;\
    gpg --keyserver keys.gnupg.net --recv-key 0xD744D55EACDA69FF;\
    gpg --export -a "FusionDirectory Project Signing Key <contact@fusiondirectory.org>" > /tmp/FD-archive-key;\
    apt-key add /tmp/FD-archive-key;\
    apt-get update;\
    apt-get -y install fusiondirectory-schema


COPY init_slapd.sh /usr/local/sbin

RUN chmod +x /usr/local/sbin/init_slapd.sh

ENTRYPOINT ["init_slapd.sh"]

EXPOSE 389

CMD ["/usr/sbin/slapd","-h","ldap:/// ldapi:///","-g","openldap","-u","openldap","-F","/etc/ldap/slapd.d","-d","0"]