FROM debian:stretch

MAINTAINER anarcat@debian.org

ENV DEBIAN_FRONTEND noninteractive
ENV USER airsonic
ENV HOME /var/airsonic

VOLUME "$HOME"

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    apt-get update && \
    apt-get dist-upgrade --yes --no-install-recommends --no-install-suggests && \
    apt-get install --yes --no-install-recommends --no-install-suggests \
            locales \
            curl \
            ca-certificates \
            openjdk-8-jre-headless \
            flac \
            lame \
            ffmpeg \
            && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Create a new user account with UID/GID at least 10000.
    # This makes it easier to keep host and docker accounts apart.
    useradd --no-log-init --home "$HOME" -M "$USER" -K UID_MIN=10000 -K GID_MIN=10000 && \
    mkdir -p $HOME && \
    chown $USER:$USER $HOME
    rm -rf /usr/local/tomcat/webapps &&\
    mkdir -p /usr/local/tomcat/webapps

ENV LC_ALL en_US.UTF-8

COPY keyring.gpg /usr/local/tomcat/webapps/keyring.gpg

# Download and setup airsonic
RUN curl -SL -o /usr/local/tomcat/webapps/ROOT.war https://github.com/airsonic/airsonic/releases/download/v10.3.1/airsonic.war &&\
  curl -SL -o /usr/local/tomcat/webapps/ROOT.war.asc https://github.com/airsonic/airsonic/releases/download/v10.3.1/airsonic.war.asc && \
  gpgv --keyring /usr/local/tomcat/webapps/keyring.gpg /usr/local/tomcat/webapps/ROOT.war.asc /usr/local/tomcat/webapps/ROOT.war && \
	rm /usr/local/tomcat/webapps/keyring.gpg && \
	chmod a+r /usr/local/tomcat/webapps/ROOT.war && \
	mkdir -p "$SONIC_DIR"/transcode && \
	ln -s /usr/bin/flac /usr/bin/lame /usr/bin/ffmpeg "$SONIC_DIR"/transcode

EXPOSE 8080

USER "$USER"

ENTRYPOINT ["/usr/bin/java", \
     "-Djava.awt.headless=true", \
     "-jar", \
     "/usr/local/tomcat/webapps/ROOT.war"]`
