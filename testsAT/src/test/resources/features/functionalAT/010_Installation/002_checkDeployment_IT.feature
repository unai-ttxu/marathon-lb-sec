@rest
@mandatory(BOOTSTRAP_IP,REMOTE_USER,PEM_FILE_PATH,DCOS_PASSWORD)
Feature: [QATM-1870] Check Marathon-LB deployment

  Scenario:[Setup] Retrieve info from bootstrap
    Given I open a ssh connection to '${BOOTSTRAP_IP}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I obtain basic information from bootstrap

  Scenario:[01] Check correct deployment
    Given I authenticate to DCOS cluster '!{DCOS_IP}' using email '!{DCOS_USER}' with user '${REMOTE_USER}' and pem file '${PEM_FILE_PATH}' over SSH port '${EOS_NEW_SSH_PORT:-22}'
    And I set sso token using host '!{EOS_ACCESS_POINT}' with user '!{DCOS_USER}' and password '${DCOS_PASSWORD}' and tenant '!{DCOS_TENANT}'
    And I securely send requests to '!{EOS_ACCESS_POINT}:443'
    When in less than '500' seconds, checking each '20' seconds, I send a 'GET' request to '/service/deploy-api/deployments/service?instanceName=marathonlb' so that the response contains '"healthy":1'
    And in less than '500' seconds, checking each '20' seconds, I send a 'GET' request to '/service/deploy-api/deployments/service?instanceName=marathonlb' so that the response contains '"status":2'
    And in less than '500' seconds, checking each '20' seconds, I send a 'GET' request to '/service/deploy-api/deployments/service?instanceName=marathonlb' so that the response contains '"state":"TASK_RUNNING"'

  Scenario:[02] Obtain node where marathon-lb-sec is running
    Given I authenticate to DCOS cluster '!{DCOS_IP}' using email '!{DCOS_USER}' with user '${REMOTE_USER}' and pem file '${PEM_FILE_PATH}' over SSH port '${EOS_NEW_SSH_PORT:-22}'
    And I set sso token using host '!{EOS_ACCESS_POINT}' with user '!{DCOS_USER}' and password '${DCOS_PASSWORD}' and tenant '!{DCOS_TENANT}'
    And I securely send requests to '!{EOS_ACCESS_POINT}:443'
    When I send a 'GET' request to '/service/deploy-api/deployments/service?instanceName=marathonlb'
    Then I save element '$.tasks[?(@.state=="TASK_RUNNING")]' in environment variable 'publicHostIP'
    And I run 'echo '!{publicHostIP}' | jq -r .[].host' locally and save the value in environment variable 'publicHostIP'

  Scenario:[03] Make sure service is ready
    Given I send requests to '!{publicHostIP}:9090'
    When I send a 'GET' request to '/_haproxy_health_check'
    Then the service response status must be '200'
    When I send a 'GET' request to '/_haproxy_getconfig'
    Then the service response status must be '200'