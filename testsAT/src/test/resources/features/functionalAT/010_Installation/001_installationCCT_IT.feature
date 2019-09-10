@rest
@mandatory(BOOTSTRAP_IP,REMOTE_USER,PEM_FILE_PATH,DCOS_TENANT,MLB_FLAVOUR,DCOS_USER,DCOS_PASSWORD)
Feature: [QATM-1870] Marathon-LB installation

  Scenario:[Setup][01] Prepare prerequisites
    Given I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I obtain basic information from bootstrap
    And I set tenant variables
    And I set variables to login in custom tenant
    And I run 'echo ''' locally and save the value in environment variable 'UNIVERSE_MLB_VERSION'
    And I run 'echo ''' locally and save the value in environment variable 'MLB_INSTALLATION_TENANT'

  @runOnEnv(UNIVERSE_MARATHONLB_VERSION)
  Scenario:[Setup][02] Update variables with multitenant configuration
    Given I save '/${UNIVERSE_MARATHONLB_VERSION}' in variable 'UNIVERSE_MLB_VERSION'
    And I save '?tenantId=${DCOS_TENANT}' in variable 'MLB_INSTALLATION_TENANT'

  Scenario:[01] Get schema to install Marathon-LB
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '!{DCOS_USER}' with user '${REMOTE_USER}' and pem file '${PEM_FILE_PATH}' over SSH port '${EOS_NEW_SSH_PORT:-22}'
    Given I set sso token using host '!{EOS_ACCESS_POINT}' with user '!{DCOS_TENANT_USER}' and password '!{DCOS_TENANT_PASSWORD}' and tenant '!{CC_TENANT}'
    And I securely send requests to '!{EOS_ACCESS_POINT}:443'
    Given I send a 'GET' request to '/service/deploy-api/deploy/${MARATHON_LB_SERVICE:-marathon-lb}/${MLB_FLAVOUR}!{UNIVERSE_MLB_VERSION}/schema?level=1'
    Then I save element '$' in environment variable 'marathonlb-json-schema'
    And I run 'echo !{marathonlb-json-schema}' locally
    And I convert jsonSchema '!{marathonlb-json-schema}' to json and save it in variable 'marathonlb-${MLB_FLAVOUR}.json'
    And I run 'echo '!{marathonlb-${MLB_FLAVOUR}.json}' > target/test-classes/schemas/marathonlb-${MLB_FLAVOUR}.json' locally
    When I send a 'POST' request to '/service/deploy-api/deploy/${MARATHON_LB_SERVICE:-marathon-lb}/${MLB_FLAVOUR}!{UNIVERSE_MLB_VERSION}/schema!{MLB_INSTALLATION_TENANT}' based on 'schemas/marathonlb-${MLB_FLAVOUR}.json' as 'json' with:
      |$.general.resources.INSTANCES     | REPLACE | ${INSTANCE:-1}                      | number |
      |$.general.resources.CPUs          | REPLACE | ${SERVICE_CPU:-2}                   | number |
      |$.general.resources.MEM           | REPLACE | ${SERVICE_MEM:-1024}                | number |
      |$.general.resources.DISK          | REPLACE | ${SERVICE_DISK:-0}                  | number |
    Then the service response status must be '202'
    And I run 'rm -f target/test-classes/schemas/cct/marathonlb-${MLB_FLAVOUR}.json' locally

  Scenario:[02] Check correct deployment
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '!{DCOS_USER}' with user '${REMOTE_USER}' and pem file '${PEM_FILE_PATH}' over SSH port '${EOS_NEW_SSH_PORT:-22}'
    And I set sso token using host '!{EOS_ACCESS_POINT}' with user '!{DCOS_USER}' and password '${DCOS_PASSWORD}' and tenant '!{CC_TENANT}'
    And I securely send requests to '!{EOS_ACCESS_POINT}:443'
    When in less than '500' seconds, checking each '20' seconds, I send a 'GET' request to '/service/deploy-api/deployments/service?instanceName=marathonlb' so that the response contains '"healthy":1'
    And in less than '500' seconds, checking each '20' seconds, I send a 'GET' request to '/service/deploy-api/deployments/service?instanceName=marathonlb' so that the response contains '"status":2'
    And in less than '500' seconds, checking each '20' seconds, I send a 'GET' request to '/service/deploy-api/deployments/service?instanceName=marathonlb' so that the response contains '"state":"TASK_RUNNING"'

  Scenario:[03] Obtain node where marathon-lb-sec is running
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '!{DCOS_USER}' with user '${REMOTE_USER}' and pem file '${PEM_FILE_PATH}' over SSH port '${EOS_NEW_SSH_PORT:-22}'
    And I set sso token using host '!{EOS_ACCESS_POINT}' with user '!{DCOS_USER}' and password '${DCOS_PASSWORD}' and tenant '!{CC_TENANT}'
    And I securely send requests to '!{EOS_ACCESS_POINT}:443'
    When I send a 'GET' request to '/service/deploy-api/deployments/service?instanceName=marathonlb'
    Then I save element '$' in environment variable 'publicHostIP'
    And I run 'echo '!{publicHostIP}' | jq -r .tasks[].host' locally and save the value in environment variable 'publicHostIP'

  Scenario:[04] Make sure service is ready
    Given I send requests to '!{publicHostIP}:9090'
    When I send a 'GET' request to '/_haproxy_health_check'
    Then the service response status must be '200'
    When I send a 'GET' request to '/_haproxy_getconfig'
    Then the service response status must be '200'