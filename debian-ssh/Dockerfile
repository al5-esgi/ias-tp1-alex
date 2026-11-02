FROM debian:12-slim

# openssh-server : le serveur SSH
# sudo           : élévation de droits pour l'utilisateur
# python3        : requis si on cible ce conteneur avec Ansible plus tard
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server sudo python3 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

ARG SSH_USER=debian
ENV SSH_USER=${SSH_USER}

RUN useradd -m -s /bin/bash "${SSH_USER}" \
    && echo "${SSH_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${SSH_USER}" \
    && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22

# Le mot de passe est fixé au démarrage (variable SSH_PASSWORD), pas dans l'image
CMD ["sh", "-c", "echo \"${SSH_USER}:${SSH_PASSWORD:?SSH_PASSWORD manquant}\" | chpasswd && exec /usr/sbin/sshd -D -e"]
