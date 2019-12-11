@rest
@mandatory(BOOTSTRAP_IP,REMOTE_USER,PEM_FILE_PATH,EOS_INSTALLER_VERSION,DCOS_PASSWORD,DCOS_CLI_HOST,DCOS_CLI_USER,DCOS_CLI_PASSWORD)
Feature: Deploying marathon-lb-sec with client certificate

  @include(feature:../010_Installation/002_checkDeployment_IT.feature,scenario:[Setup] Retrieve info from bootstrap)
  @include(feature:../010_Installation/002_checkDeployment_IT.feature,scenario:[02] Obtain node where marathon-lb-sec is running)
  Scenario:[01] Obtain marathon-lb node
    Then I wait '5' seconds

  Scenario:[02] Deploying marathon-lb-sec with a clients certificate
    Given I run 'sudo cp /etc/hosts /tmp/hostbackup' locally
    And I run 'cat /etc/hosts | grep nginx-qa.!{EOS_DNS_SEARCH} || echo "!{publicHostIP} nginx-qa.!{EOS_DNS_SEARCH}" | sudo tee -a /etc/hosts' locally
    Then I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    And I outbound copy 'src/test/resources/scripts/marathon-lb-manage-certs.sh' through a ssh connection to '/tmp'
    And I run 'sed -i s/"DNS:nginx-qa.labs.stratio.com"/"DNS:nginx-qa.!{EOS_DNS_SEARCH}"/g /tmp/marathon-lb-manage-certs.sh' in the ssh connection
    And I run 'cd /tmp && sudo chmod +x marathon-lb-manage-certs.sh' in the ssh connection
    And I run 'sudo mv /tmp/marathon-lb-manage-certs.sh /stratio_volume/marathon-lb-manage-certs.sh' in the ssh connection
    And I run 'sudo docker exec -t paas-bootstrap /stratio_volume/marathon-lb-manage-certs.sh' in the ssh connection
    And I wait '60' seconds
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I outbound copy 'src/test/resources/schemas/nginx-qa-config.json' through a ssh connection to '/tmp'
    And I run 'sed -i -e '/"HAPROXY_0_PATH": null,/d' -e 's/"HAPROXY_0_VHOST": "nginx-qa.labs.stratio.com"/"HAPROXY_0_VHOST": "nginx-qa.!{EOS_DNS_SEARCH}"/g' /tmp/nginx-qa-config.json ; dcos marathon app add /tmp/nginx-qa-config.json ; rm -f /tmp/nginx-qa-config.json' in the ssh connection
    Then in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep nginx-qa | grep R | wc -l' contains '1'
    When I run 'dcos task | grep marathonlb | tail -1 | awk '{print $5}'' in the ssh connection and save the value in environment variable 'TaskID'
    And I run 'dcos marathon task list nginx-qa | awk '{print $5}' | grep nginx-qa' in the ssh connection and save the value in environment variable 'nginx-qaTaskId'
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{nginx-qaTaskId} | grep TASK_RUNNING | wc -l' contains '1'
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{nginx-qaTaskId} | grep healthCheckResults | wc -l' contains '1'
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{nginx-qaTaskId} | grep  '"alive": true' | wc -l' contains '1'
    Given I run 'dcos marathon app remove --force nginx-qa' in the ssh connection
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos task | awk '{print $1}' | grep -c nginx-qa' contains '0'
    And I run 'sudo cp /tmp/hostbackup /etc/hosts' locally

  Scenario:[03] Deleting files
    Then I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    And I run 'sudo rm -rf /stratio_volume/certs_client_marathonlb.list ; sudo rm -rf /stratio_volume/marathon-lb-cert-backup.json ; sudo rm -rf /stratio_volume/marathon-lb-manage-certs.sh' in the ssh connection

