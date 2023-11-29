FROM phusion/baseimage:jammy-1.0.1
ARG ssh_pub_key
ARG ssh_prv_key

USER root
CMD [ "/sbin/my_init" ]

RUN rm -f /etc/service/sshd/down && /etc/my_init.d/00_regen_ssh_host_keys.sh > /dev/null 2>&1
RUN mkdir -p /root/.ssh

RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
  echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
  chmod 600 /root/.ssh/id_rsa && \
  chmod 600 /root/.ssh/id_rsa.pub && \
  cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

RUN apt-get update && \
  apt-get -y install sudo && \
  echo 'root    ALL=(ALL:ALL) ALL' >> /etc/sudoers && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
  usermod -aG sudo root
