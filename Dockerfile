# Builds docker image for subsonic
FROM ubuntu:trusty
MAINTAINER Carlos Hernandez <carlos@techbyte.ca>

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Set locale to UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales

# Update Ubuntu
RUN apt-mark hold initscripts udev plymouth mountall
RUN apt-get update && apt-get -qy dist-upgrade && apt-get -q update

# Set user nobody to uid and gid of unRAID
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

# install dependencies for subsonic
RUN apt-get install -qy openjdk-6-jre
RUN apt-get clean

# install subsonic
ADD http://downloads.sourceforge.net/project/subsonic/subsonic/4.9/subsonic-4.9.deb /tmp/subsonic.deb
RUN dpkg -i /tmp/subsonic.deb && rm /tmp/subsonic.deb

# Create hardlinks to the transcoding binaries.
# This way we can mount a volume over /var/subsonic.
# Apparently, Subsonic does not accept paths in the Transcoding settings.
# If you mount a volume over /var/subsonic, create symlinks
# <host-dir>/var/subsonic/transcode/ffmpeg -> /usr/local/bin/ffmpeg
# <host-dir>/var/subsonic/transcode/lame -> /usr/local/bin/lame
RUN ln /var/subsonic/transcode/ffmpeg /var/subsonic/transcode/lame /usr/local/bin
RUN chown -R nobody:users /var/subsonic

ADD startup.sh /startup.sh

VOLUME [/subsonic]
VOLUME [/music]
VOLUME [/podcasts]

EXPOSE 4040
EXPOSE 4050

USER nobody
ENTRYPOINT ["/startup.sh"]