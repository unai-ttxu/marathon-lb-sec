@rest
Feature: [QATM-1870] Uninstall CCT

  Scenario: [QATM-1870] Uninstall MarathonLB
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER:-admin}' with user '${REMOTE_USER:-operador}' and pem file 'src/test/resources/credentials/${PEM_FILE:-key.pem}'
    And I securely send requests to '${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}:443'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user 'root' and password 'stratio'
    When I send a 'DELETE' request to '/service/deploy-api/deploy/uninstall?app=${MARATHON-LB-ID:-marathon-lb-sec}'
    # Check Uninstall in DCOS
    Then in less than '600' seconds, checking each '10' seconds, the command output 'dcos task | grep ${MARATHON-LB-ID:-marathon-lb-sec} | wc -l' contains '0'
    # Check Uninstall in CCT-API
    And in less than '200' seconds, checking each '20' seconds, I send a 'GET' request to '/service/deploy-api/deploy/status/all' so that the response does not contains '${MARATHON-LB-ID:-marathon-lb-sec}'