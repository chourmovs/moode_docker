#!/bin/bash

printf "\ec"
echo ""
echo "****************************************************"
echo "*    Moode on docker multiarch install script    *"
echo "*             By chourmovs v 1.1                  *"
echo "****************************************************"
echo ""
echo ""
echo "************************************************************************"
echo "*    create container with systemd in priviledged mode and start it    *"
echo "************************************************************************"
echo ""
# sudo mkdir /home/moode && sudo chown volumio:volumio /home/moode && sudo chmod 777 /home/moode
docker volume create moode
# sudo chown -R volumio /var/lib/docker/

docker run --privileged --rm tonistiigi/binfmt --install linux/arm64
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes # This step will execute the registering scripts
docker create --name debian-moode --restart always --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v moode:/tmp:rw -v moode:/run:rw --device=/dev/kvm --net host --privileged -e LANG=C.UTF-8 --cap-add=NET_ADMIN --security-opt seccomp:unconfined --platform linux/arm64 robxme/raspbian-stretch /lib/systemd/systemd

docker container start debian-moode

echo ""
echo "*********************************************"
echo "*    install moode player (container side)  *"
echo "*********************************************"
echo ""
docker exec -ti debian-moode /bin/bash -c "apt-get update -y ; sleep 3 ; apt-get upgrade -y"
docker exec -ti debian-moode /bin/bash -c "apt-get install -y curl sudo libxaw7 ssh libsndfile1 libsndfile1-dev cifs-utils nfs-common"
docker exec -ti debian-moode /bin/bash -c "apt --fix-broken install -y"

echo ""
echo ""
echo "Willchange ssh port to 2222 to fix openssh"
echo ""
echo ""
sleep 2

docker exec -ti debian-moode /bin/bash -c "sudo sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config;"
docker exec -ti debian-moode /bin/bash -c "systemctl restart sshd"
docker exec -ti debian-moode /bin/bash -c "curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye bash -"
docker exec -ti debian-moode /bin/bash -c "apt-get update -y | apt-get install moode-player -y --fix-missing"
echo ""
echo ""
echo "In general this long install return error, next move will try to fix this"
sleep 2
echo ""


docker exec -ti debian-moode /bin/bash -c "apt --fix-broken install -y"
sleep 2
docker exec -ti debian-moode /bin/bash -c "apt-get install moode-player -y --fix-missing"
sleep 2
docker exec -ti debian-moode /bin/bash -c "apt upgrade -y"
#sleep 2
docker exec -ti debian-moode /bin/bash -c "exit"       

echo ""
echo "****************************************"
echo "*    restart moode player (host side)  *"
echo "****************************************"

docker container stop debian-moode
docker container start debian-moode

echo ""
echo ""
echo "***************************************"
echo "*    configure nginx (container side) *"
echo "***************************************"
echo ""
echo "Will change moode http port to 8008 to avoid conflict with volumio front"
echo ""
echo ""
sleep 2
docker exec -ti debian-moode /bin/bash -c "sudo sed -i 's/80 /8008 /g' /etc/nginx/sites-available/moode-http.conf"
docker exec -ti debian-moode /bin/bash -c "systemctl restart nginx"

echo ""
echo "****************************"
echo "*    Access Moode web UI   *"
echo "****************************"
echo ""
echo "Your device will now restart"
echo ""
echo ""
echo "CTRL+CLIC on http://volumio:8008"
echo ""
echo "Enjoy"
# sudo reboot

