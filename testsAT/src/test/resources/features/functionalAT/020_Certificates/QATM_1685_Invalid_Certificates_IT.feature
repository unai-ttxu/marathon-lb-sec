@rest
Feature: Marathon-lb not able to run without valid certificates in Vault

  Scenario: [01] Delete valid marathon-lb certificate in vcli
    Given I open a ssh connection to '${BOOTSTRAP_IP}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I outbound copy 'src/test/resources/scripts/marathon-lb-invalid-certs.sh' through a ssh connection to '/tmp'
    And I run 'cp /stratio_volume/certs.list certs_custom_app_marathonlb.list' in the ssh connection
    And I run 'cd /tmp && sudo chmod +x marathon-lb-invalid-certs.sh' in the ssh connection
    And I run 'sudo mv /tmp/marathon-lb-invalid-certs.sh /stratio_volume/marathon-lb-invalid-certs.sh' in the ssh connection
    And I run 'sudo docker ps | grep eos-installer | awk '{print $1}'' in the ssh connection and save the value in environment variable 'containerId'
    And I run 'sudo docker exec -t !{containerId} /stratio_volume/marathon-lb-invalid-certs.sh' in the ssh connection

  @include(feature:../010_Installation/010_installation.feature,scenario:[02] Create installation config file)
  Scenario: Prepare configuration to install Marathon-lb
    Then I wait '5' seconds

  Scenario: [03] Install using config file and cli
    #Copy DEPLOY JSON to DCOS-CLI
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I run 'dcos marathon app show marathonlb | jq -r .container.docker.image | sed 's/.*://g'' in the ssh connection and save the value in environment variable 'marathonlbversion'
    When I outbound copy 'target/test-classes/config.!{marathonlbversion}.json' through a ssh connection to '/tmp/'
    And I run 'dcos package install --yes --package-version=!{marathonlbversion} --options=/tmp/config.!{marathonlbversion}.json ${PACKAGE_MARATHON_LB:-marathon-lb-sec}' in the ssh connection
    Then the command output contains 'Marathon-lb DC/OS Service has been successfully installed!'
    And I run 'rm -f /tmp/config.!{marathonlbversion}.json' in the ssh connection
    And I wait '45' seconds
#    Marathon-lb-sec is not installed because certificates are incorrect
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w marathonlb. | wc -l' contains '0'

  Scenario: Restore Certificates for Marathon-lb-sec
    Given I open a ssh connection to '${BOOTSTRAP_IP}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I outbound copy 'src/test/resources/scripts/marathon-lb-restore-certs.sh' through a ssh connection to '/tmp'
    And I run 'cp /stratio_volume/certs.list certs_custom_app_marathonlb.list' in the ssh connection
    And I run 'cd /tmp && sudo chmod +x marathon-lb-restore-certs.sh' in the ssh connection
    And I run 'sudo mv /tmp/marathon-lb-restore-certs.sh /stratio_volume/marathon-lb-restore-certs.sh' in the ssh connection
    And I run 'sudo docker ps | grep eos-installer | awk '{print $1}'' in the ssh connection and save the value in environment variable 'containerId'
    And I run 'sudo docker exec -t !{containerId} /stratio_volume/marathon-lb-restore-certs.sh' in the ssh connection

    #Uninstalling marathon-lb-sec
  @include(feature:../099_Uninstall/purge.feature,scenario:[01] marathon-lb-sec can be uninstalled using cli)
  Scenario: Uninstall marathon-lb-sec
    Then I wait '5' seconds
