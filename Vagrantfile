# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/jammy64"   # Ubuntu 22.04 LTS

  # Expone el puerto 8080 de la VM en el 8080 del anfitrión
  config.vm.network "forwarded_port", guest: 8080, host: 8080

  config.vm.provider "virtualbox" do |vb|
    vb.name   = "uxilibris-server"
    vb.memory = 2048   # 2 GB RAM mínimo para Spring Boot
    vb.cpus   = 2
  end

  # Provisión: instala Docker y arranca los contenedores
  config.vm.provision "shell", inline: <<-SHELL
    set -e

    echo ">>> Instalando Docker..."
    apt-get update -q
    apt-get install -y -q ca-certificates curl gnupg lsb-release

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
      | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -q
    apt-get install -y -q docker-ce docker-ce-cli containerd.io docker-compose-plugin

    systemctl start docker
    systemctl enable docker
    usermod -aG docker vagrant

    echo ">>> Arrancando UxiLibris..."
    cd /vagrant
    docker compose up -d --build

    echo ">>> ¡Listo! Backend disponible en http://localhost:8080"
  SHELL
end