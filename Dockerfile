ENV DEBIAN_FRONTEND noninteractive

#FROM docker.io/balenalib/armv7hf-debian as base
FROM docker.io/navikey/raspbian-bullseye as base
FROM docker.io/navikey/raspbian-bullseye
#FROM docker.io/balenalib/armv7hf-debian

COPY --from=base /bin/sh /bin/sh.real

RUN [ "cross-build-start" ]


RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils \
       sudo systemd systemd-sysv \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Make sure systemd doesn't start agettys on tty[1-6].
RUN rm -f /lib/systemd/system/multi-user.target.wants/getty.target

VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]


RUN [ "cross-build-end" ]

ENV DEBIAN_FRONTEND teletype
