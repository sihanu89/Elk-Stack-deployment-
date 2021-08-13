# Elk-Stack-deployment-
Linux and Cloud system hardening
## Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

![Elk server Network diagram](Diagrams/Elk_Network_Diagram.pdf)

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, select portions of the playbook file may be used to install only certain pieces of it, such as Filebeat.

 #### Playbook 1: 
 [DVWA_pentest_playbook](Ansible/DVWA_pentest_playbook.yml)
 ```
 ---
- name: DVWA_pentest playbook
  hosts: webservers
  become: true
  tasks:

  - name: Install docker.io
    apt:
      update_cache: yes
      name: docker.io
      state: present

  - name: Install pip3
    apt:
      name: python3-pip
      state: present

  - name: Install Docker python module
    pip:
      name: docker
      state: present

  - name: download and launch a docker we container
    docker_container:
      name: dvwa
      image: cyberxsecurity/dvwa
      state: started
      restart_policy: always
      published_ports: 80:80

  - name: Enable docker service
    systemd:
      name: docker
      enabled: yes
```
#### Playbook 2: 
 [Elk_playbook](Ansible/elk_playbook.yml)
```
 ---
- name: Config elk VM with Docker
  hosts: elk
  remote_user: azdmin
  become: true
  tasks:

    # Use apt module
    - name: Install docker.io
      apt:
        update_cache: yes
        name: docker.io
        state: present

    # Use apt module
    - name: Install python3-pip
      apt:
        name: python3-pip
        state: present

    # Use pip module
    - name: Install Docker module
      pip:
        name: docker
        state: present

    # Use systemd module
    - name: Eable service docker on boot
      systemd:
        name: docker
        enabled: yes

    # Use command module
    - name: Increase virtual memory
      command: sysctl -w vm.max_map_count=262144

    # Use sysctl module
    - name: Use more memory
      sysctl:
        name: vm.max_map_count
        value: 262144
        state: present
        reload: yes

    # Use docker_container module
    - name: download and launch a docker elk container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
        # lists the ports elk runs on
        published_ports:
          - 5601:5601
          - 9200:9200
          - 5044:5044
  ```

#### Playbook 3: 
 [Filebeat_playbook](Ansible/filebeat_playbook.yml)
```
---
- name: installing and launching filebeat
  hosts: webservers
  become: yes
  tasks:

  - name: download filebeat deb
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.0-amd64.deb

  - name: install filebeat deb
    command: dpkg -i filebeat-7.4.0-amd64.deb

  - name: drop in filebeat.yml
    copy:
      src: /etc/ansible/files/filebeat-config.yml
      dest: /etc/filebeat/filebeat.yml

  - name: enable and configure system module
    command: filebeat modules enable system

  - name: setup filebeat
    command: filebeat setup

  - name: start filebeat service
    command: service filebeat start

  - name: enable filebeat service
    systemd:
      name: filebeat
      enabled: yes
 ```
 #### Playbook 3: 
 [Metricbeat_playbook](Ansible/metricbeat_playbook.yml)
  ```
  ---
- name: Install metric beat
  hosts: webservers
  become: true
  tasks:

  - name: Download metricbeat
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.6.1-amd64.deb

  - name: Install metricbeat
    command: dpkg -i metricbeat-7.6.1-amd64.deb

  - name: drop in metricbeat config
    copy:
      src: /etc/ansible/files/metricbeat-config.yml
      dest: /etc/metricbeat/metricbeat.yml

  - name: enable and configure docker module for metricbeat
    command: metricbeat modules enable docker

  - name: setup metricbeat
    command: metricbeat setup

  - name: start metricbeat
    command: service metricbeat start

  - name: enable service metricbeat on boot
    systemd:
      name: metricbeat
      enabled: yes
 ```
 
This document contains the following details:
- Description of the Topology
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build


### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly available, in addition to restricting access to the network.

- Load balancers protect availability of web-serves by sharing client requests across several servers.
-	The advantage of using a Jump Box is that it restricts access to the network by not allowing any access other protocols except ssh and thus provides a segregation layer between the network and the user thus .So, it makes an attack harder by minimizing attack surface. Further any tools or applications in web-servers can be maintained using Jump Box.

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the configuration and system files.

-	Filebeat is used to monitor logs files.
-	Metricbeat is used to collect various types of OS data and statistics.

The configuration details of each machine may be found below.


| Name     | Function | IP Address | Operating System |
|----------|----------|------------|------------------|
| Jump Box | Gateway  | 10.0.10.4  | Linux            |
| Web-1    |   DVWA   | 10.0.10.7  | Linux            |
| Web-2    |   DVWA   | 10.0.10.8  | Linux            |
| Web-3    |   DVWA   | 10.0.10.9  | Linux            |
| Elk-1    |   Elk    | 10.1.0.4   | Linux            |


### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the Jump Box machine can accept connections from the Internet. Access to this machine is only allowed from the following IP addresses:
-	49.177.78.156

Machines within the network can only be accessed by Ansible container within the Jump Box.
-	Only the Jump Box can access to the Elk-1 using SSH. The Jump Box IP address is 10.0.10.4.

A summary of the access policies in place can be found in the table below.

| Name     | Publicly Accessible | Allowed IP Addresses |
|----------|---------------------|----------------------|
| Jump Box | Yes (SSH)           | 49.177.78.156        |
| Web-1    | Yes (HTTP)          | 49.177.78.156        |
| Web-2    | Yes (HTTP)          | 49.177.78.156        |
| Web-3    | Yes (HTTP)          | 49.177.78.156        |
| Elk-1    | Yes (HTTP)          | 49.177.78.156        |



### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because:
-	system configuration and deployment can be done consistently and quickly for all web servers at same time.
-	Ansible automation is not complex and ease to use.
-	It minimizes the attack surface as it does not require any remote server agent.  

The playbook implements the following tasks:
-	Installs Docker
-	Installs Python
-	Installs Docker's Python Module
-	Increase virtual memory to support the ELK stack
-	Increase memory to support the ELK stack
-	Download and launch the Docker ELK container

The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

![Elk docker ps output](Diagrams/Elk_Docker_ps.PNG)

### Target Machines & Beats
This ELK server is configured to monitor the following machines:
-	Web-1: 10.0.0.7
-	Web-2: 10.0.0.8
-	Web-3: 10.0.0.9

We have installed the following Beats on these machines:
-	Filebeat
-	Metricbeat

These Beats allow us to collect the following information from each machine:
-	Filebeat monitor log files and forward log data to Elasticsearch from Web servers.
-	Metricbeat periodically collects metrics from the operating system and web servers and forwards them into Elasticsearch.

### Using the Playbook
In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned: 

SSH into the control node and follow the steps below:
-	Copy the playbook file to Ansible Docker Container.
-	Update the Ansible hosts file /etc/ansible/hosts to specify which machine to install the ELK server and which to install Filebeat.
-	Update the filebeat and metricbeat configuration files to set the remote_user parameter to the admin user of the web servers.  

-	Run the playbook, and navigate to Kibana to check that the installation worked as expected.
