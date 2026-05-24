# -*- mode: ruby -*-
# vi: set ft=ruby :

# REQUISITO PREVIO: ejecuta scripts\modoA_exportar_imagen.bat en tu maquina,
# luego: git add uxilibris-web.tar.gz && git commit && git push
# El aprovisionamiento descarga esa imagen desde el repositorio clonado.

Vagrant.configure("2") do |config|

  # Debian 13 "Trixie". Si el box aun no esta disponible en Vagrant Cloud
  # puedes sustituirlo temporalmente por "debian/bookworm64" (Debian 12).
  config.vm.box = "debian/trixie64"

  # ── Red: puertos expuestos al anfitrion ────────────────────────────────────
  config.vm.network "forwarded_port", guest: 9443, host: 9443  # Portainer HTTPS
  config.vm.network "forwarded_port", guest: 80,   host: 8080  # Frontend UxiLibris

  # ── Proveedor VirtualBox ───────────────────────────────────────────────────
  config.vm.provider "virtualbox" do |vb|
    vb.name   = "uxilibris-presentacion"
    vb.memory = 2048
    vb.cpus   = 2
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--usb", "off"]
  end

  # ── Aprovisionamiento (se ejecuta solo la primera vez) ─────────────────────
  config.vm.provision "shell", inline: <<-SHELL
    set -euo pipefail

    echo "==> [1/5] Actualizando paquetes base..."
    apt-get update -q
    apt-get install -y -q ca-certificates curl git

    echo "==> [2/5] Instalando Docker Engine..."
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker vagrant
    systemctl enable docker
    systemctl start docker

    echo "==> [3/5] Clonando repositorio en /home/vagrant/uxilibris..."
    # Fuera de /vagrant (synced folder de vboxsf) para evitar restricciones
    # con symlinks y operaciones de fichero que Docker necesita internamente.
    git clone https://github.com/UxiaRD/UxiLibris.git /home/vagrant/uxilibris
    chown -R vagrant:vagrant /home/vagrant/uxilibris

    echo "==> [4/5] Cargando imagen del frontend..."
    docker load < /home/vagrant/uxilibris/uxilibris-web.tar.gz

    echo "==> Arrancando contenedor del frontend en puerto 80..."
    docker run -d \
      --name uxilibris-frontend \
      --restart unless-stopped \
      -p 80:80 \
      uxilibris-web

    echo "==> [5/5] Instalando Portainer CE..."
    docker volume create portainer_data
    docker run -d \
      --name portainer \
      --restart always \
      -p 9443:9443 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce:latest

    echo ""
    echo "========================================"
    echo "  Aprovisionamiento completado."
    echo "  Frontend  -> http://localhost:8080"
    echo "  Portainer -> https://localhost:9443"
    echo "========================================"
  SHELL
end