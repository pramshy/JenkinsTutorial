#!/bin/bash
install_docker() {  
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    sudo systemctl restart dockerd
}

install_git() {
    sudo yum install git -y
}

clone_jenkins_dockerfile() {
    git clone https://github.com/wardviaene/jenkins-docker.git
}

build_jenkins_image() {
    cd jenkins-docker && docker build -t jenkins-docker .
    cd ..
}

install_jenkins() {  
    mkdir -p /var/jenkins_home
    chown -R 1000:1000 /var/jenkins_home/
    sudo chmod 666 /var/run/docker.sock
    docker run -p 8080:8080 -p 50000:50000 -v /var/jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock -d --restart always \
    --name jenkins jenkins-docker
}

install_docker
echo "Docker installed successfully!!"

install_git
echo "Git installed successfully!!"

clone_jenkins_dockerfile
echo "Cloned jenkins dockerfile from github!!"

build_jenkins_image
echo "Jenkins image built successfully!!"

install_jenkins
echo 'Jenkins installed successfully'

# show endpoint
echo 'You should now be able to access jenkins at: http://'$(curl -s ifconfig.co)':8080'