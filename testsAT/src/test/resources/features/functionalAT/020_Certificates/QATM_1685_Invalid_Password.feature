@rest
Feature: Marathon-lb not able to run without valid password in Vault for Marathon - mesos and rest

  Scenario:[01] Delete valid marathon password in vcli
    Given I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I outbound copy 'src/test/resources/scripts/marathon-lb-invalid-password.sh' through a ssh connection to '/tmp'
    And I run 'cd /tmp && sudo chmod +x marathon-lb-invalid-password.sh' in the ssh connection
    And I run 'sudo mv /tmp/marathon-lb-invalid-password.sh /stratio_volume/marathon-lb-invalid-password.sh' in the ssh connection
    And I run 'sudo docker ps | grep eos-installer | awk '{print $1}'' in the ssh connection and save the value in environment variable 'containerId'
    And I run 'sudo docker exec -t !{containerId} /stratio_volume/marathon-lb-invalid-password.sh' in the ssh connection

  @include(feature:../010_Installation/010_installation.feature,scenario:[Install Marathon-lb][01])
  Scenario:[02]Prepare configuration to install Marathon-lb
    Then I wait '5' seconds

  Scenario:[03] Install using config file and cli
    #Copy DEPLOY JSON to DCOS-CLI
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I run 'dcos marathon app show marathonlb | jq -r .container.docker.image | sed 's/.*://g'' in the ssh connection and save the value in environment variable 'marathonlbversion'
    When I outbound copy 'target/test-classes/config.${MARATHON_LB_VERSION:-0.3.1}.json' through a ssh connection to '/tmp/'
    And I run 'dcos package install --yes --package-version=!{marathonlbversion} --options=/tmp/config.!{marathonlbversion}.json ${PACKAGE_MARATHON_LB:-marathon-lb-sec}' in the ssh connection
    Then the command output contains 'Marathon-lb DC/OS Service has been successfully installed!'
    And I run 'rm -f /tmp/config.!{marathonlbversion}.json' in the ssh connection
    And I wait '45' seconds
#    Marathon-lb-sec is not installed because passwords for marathon are incorrect
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w marathonlb. | wc -l' contains '0'

  Scenario: Restore Password for Marathon - mesos and rest
    Given I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I outbound copy 'src/test/resources/scripts/marathon-lb-restore-password.sh' through a ssh connection to '/tmp'
    And I run 'cd /tmp && sudo chmod +x marathon-lb-restore-password.sh' in the ssh connection
    And I run 'sudo mv /tmp/marathon-lb-restore-password.sh /stratio_volume/marathon-lb-restore-password.sh' in the ssh connection
    And I run 'sudo docker ps | grep eos-installer | awk '{print $1}'' in the ssh connection and save the value in environment variable 'containerId'
    And I run 'sudo docker exec -t !{containerId} /stratio_volume/marathon-lb-restore-password.sh' in the ssh connection

    #Uninstalling marathon-lb-sec
  @include(feature:../099_Uninstall/purge.feature,scenario:marathon-lb-sec can be uninstalled using cli)
  Scenario: Uninstall marathon-lb-sec
    Then I wait '5' seconds
