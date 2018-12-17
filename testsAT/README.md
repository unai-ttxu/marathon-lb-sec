# marathon-lb-sec

	Marathon-lb-sec for Stratio; 14-dic-18

#Instalación
mvn clean verify -Dgroups=nightly -DDCOS_CLI_HOST=172.17.0.3 -DCLUSTER_ID=nightly -DDCOS_IP=10.200.0.156 -DBOOTSTRAP_IP=10.200.0.155 -DCLUSTER_SSO=nightly.labs.stratio.com

#Pruebas

##### Nightly
mvn clean verify -Dgroups=nightly -DDCOS_CLI_HOST=172.17.0.3 -DDCOS_IP=10.200.0.156 -DCLUSTER_SSO=nightly.labs.stratio.com -DBOOTSTRAP_IP=10.200.0.155 -DCLUSTER_ID=nightly

##### iptables
mvn clean verify -Dgroups=iptables -DDCOS_CLI_HOST=172.17.0.3 -DDCOS_IP=10.200.0.156 -DCLUSTER_SSO=nightly.labs.stratio.com -DBOOTSTRAP_IP=10.200.0.155 -DCLUSTER_ID=nightly
