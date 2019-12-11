@rest
@mandatory(BOOTSTRAP_IP,REMOTE_USER,PEM_FILE_PATH,EOS_INSTALLER_VERSION,DCOS_PASSWORD,DCOS_CLI_HOST,DCOS_CLI_USER,DCOS_CLI_PASSWORD)
Feature:[QATM-2113] Download certificates only of new deployed apps - Invalid certs for nginx-qa

  @include(feature:../010_Installation/002_checkDeployment_IT.feature,scenario:[Setup] Retrieve info from bootstrap)
  @include(feature:../010_Installation/002_checkDeployment_IT.feature,scenario:[02] Obtain node where marathon-lb-sec is running)
  Scenario:[01] Obtain marathon-lb node
    Then I wait '5' seconds

  @runOnEnv(EOS_INSTALLER_VERSION<0.22.11)
  Scenario:[02a] Preparing files
    Then I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I outbound copy 'src/test/resources/scripts/nginx-qa-invalid-certs.sh' through a ssh connection to '/tmp'
    And I run 'cp /stratio_volume/certs.list certs_custom_app_nginxqa.list' in the ssh connection
#
  @runOnEnv(EOS_INSTALLER_VERSION=0.22.11||EOS_INSTALLER_VERSION>0.22.11)
  Scenario:[02b] Preparing files
    Then I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    And I run 'sudo touch /stratio_volume/certs.list' in the ssh connection
    Then I outbound copy 'src/test/resources/scripts/nginx-qa-invalid-certs.sh' through a ssh connection to '/tmp'
    And I run 'cp /stratio_volume/certs.list certs_custom_app_nginxqa.list' in the ssh connection
#
  Scenario:[03] Delete valid nginx-qa certificate in vcli
    Then I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    And I run 'cd /tmp && sudo chmod +x nginx-qa-invalid-certs.sh' in the ssh connection
    And I run 'sudo mv /tmp/nginx-qa-invalid-certs.sh /stratio_volume/nginx-qa-invalid-certs.sh' in the ssh connection
    And I run 'sudo docker exec -t paas-bootstrap /stratio_volume/nginx-qa-invalid-certs.sh' in the ssh connection

  Scenario:[04] Deploying nginx-qa without valid certificate
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I outbound copy 'src/test/resources/schemas/nginx-qa-config.json' through a ssh connection to '/tmp'
    And I run 'sed -i '/"HAPROXY_0_PATH": null,/d' /tmp/nginx-qa-config.json ; dcos marathon app add /tmp/nginx-qa-config.json ; rm -f /tmp/nginx-qa-config.json' in the ssh connection
    Then in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep nginx-qa | grep R | wc -l' contains '1'
    When I run 'dcos task | grep marathon.*lb.* | tail -1 | awk '{print $5}'' in the ssh connection and save the value in environment variable 'TaskID'
    And I run 'dcos marathon task list nginx-qa | awk '{print $5}' | grep nginx-qa' in the ssh connection and save the value in environment variable 'nginx-qaTaskId'
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{nginx-qaTaskId} | grep TASK_RUNNING | wc -l' contains '1'
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{nginx-qaTaskId} | grep healthCheckResults | wc -l' contains '1'
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{nginx-qaTaskId} | grep  '"alive": true' | wc -l' contains '1'
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos task log --lines 100 !{TaskID} 2>/dev/null | grep 'Does not exists certificate for /nginx-qa' | wc -l' contains '1'

  Scenario:[05] Uninstall nginx-qa
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    Given I run 'dcos marathon app remove --force nginx-qa' in the ssh connection
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos task | awk '{print $1}' | grep -c nginx-qa' contains '0'

  Scenario:[06] Restore Certificates for nginx-qa and remove files
    Then I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I outbound copy 'src/test/resources/scripts/nginx-qa-restore-certs.sh' through a ssh connection to '/tmp'
    And I run 'sed -i s/"DNS:nginx-qa.labs.stratio.com"/"DNS:nginx-qa.!{EOS_DNS_SEARCH}"/g /tmp/nginx-qa-restore-certs.sh' in the ssh connection
    And I run 'cp /stratio_volume/certs.list certs_custom_app_nginxqa.list' in the ssh connection
    And I run 'cd /tmp && sudo chmod +x nginx-qa-restore-certs.sh' in the ssh connection
    And I run 'sudo mv /tmp/nginx-qa-restore-certs.sh /stratio_volume/nginx-qa-restore-certs.sh' in the ssh connection
    And I run 'sudo docker exec -t paas-bootstrap /stratio_volume/nginx-qa-restore-certs.sh' in the ssh connection
    And I run 'sudo rm -rf /stratio_volume/nginx-qa-cert-backup.json ; sudo rm -rf /stratio_volume/certs_restore_nginx-qa.list ; sudo rm -rf /stratio_volume/nginx-qa-restore-certs.sh ; sudo rm -rf /tmp/nginx-qa-restore-certs.sh' in the ssh connection

  @runOnEnv(EOS_INSTALLER_VERSION=0.22.11||EOS_INSTALLER_VERSION>0.22.11)
  Scenario:[07] Remove files
    Then I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    And I run 'sudo rm -rf /stratio_volume/certs.list ; sudo rm -rf /stratio_volume/nginx-qa-invalid-certs.sh ' in the ssh connection