@rest
Feature:[QATM-1870] Uninstall CCT

  Scenario:[01] Obtain info from bootstrap
    Given I open a ssh connection to '${BOOTSTRAP_IP}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I obtain basic information from bootstrap

  Scenario:[02] Uninstall MarathonLB
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '!{DCOS_USER}' with user '${REMOTE_USER}' and pem file '${PEM_FILE_PATH}'
    And I securely send requests to '!{EOS_ACCESS_POINT}:443'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    When I send a 'DELETE' request to '/service/deploy-api/deploy/uninstall?app=marathonlb'
    # Check Uninstall in DCOS
    Then in less than '600' seconds, checking each '10' seconds, the command output 'dcos task | grep marathonlb | wc -l' contains '0'
    # Check Uninstall in CCT-API
    And in less than '200' seconds, checking each '20' seconds, I send a 'GET' request to '/service/deploy-api/deploy/status/all' so that the response does not contains 'marathonlb'