FROM ubuntu:latest

COPY no_interaction_install.sh /tmp

RUN /bin/bash /tmp/no_interaction_install.sh

EXPOSE 389

CMD ["slapd","-d","0"]