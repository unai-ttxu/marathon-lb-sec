@rest
Feature: [QATM-1870] Service_Installation

  Scenario:[01] Obtain info from bootstrap
    Given I open a ssh connection to '${BOOTSTRAP_IP}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I obtain basic information from bootstrap

  Scenario:[02] Marathon-LB Simple Installation - Deploy service
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '!{DCOS_USER}' with user '${REMOTE_USER}' and pem file '${PEM_FILE_PATH}'
    And I securely send requests to '!{EOS_ACCESS_POINT}:443'
    # Obtain schema
    When I send a 'GET' request to '/service/deploy-api/deploy/marathon-lb/${MLB_FLAVOUR}/schema?level=1'
    Then I save element '$' in environment variable 'marathonlb-json-schema'
    And I run 'echo !{marathonlb-json-schema}' locally
    # Convert json
    And I convert jsonSchema '!{marathonlb-json-schema}' to json and save it in variable 'marathonlb-basic.json'
    And I run 'echo '!{marathonlb-basic.json}' > target/test-classes/schemas/marathonlb-basic.json' locally
    # Launch installation
    When I send a 'POST' request to '/service/deploy-api/deploy/marathon-lb/${MLB_FLAVOUR}/schema' based on 'schemas/marathonlb-basic.json' as 'json' with:
#      |$.general.serviceId               | UPDATE  | marathonlb           | n/a    |
      |$.general.resources.INSTANCES     | REPLACE | ${INSTANCE:-1}                      | number |
      |$.general.resources.CPUs          | REPLACE | ${SERVICE_CPU:-2}                   | number |
      |$.general.resources.MEM           | REPLACE | ${SERVICE_MEM:-1024}                | number |
      |$.general.resources.DISK          | REPLACE | ${SERVICE_DISK:-0}                  | number |

    Then the service response status must be '202'
    And I run 'rm -f target/test-classes/schemas/cct/marathonlb-basic.json' locally

  Scenario:[03] Marathon-LB Installation - Status
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '!{DCOS_USER}' with user '${REMOTE_USER}' and pem file '${PEM_FILE_PATH}'
    And I securely send requests to '!{EOS_ACCESS_POINT}:443'
    #Check status in API
    When in less than '500' seconds, checking each '20' seconds, I send a 'GET' request to '/service/deploy-api/deploy/status/service?service=/marathonlb' so that the response contains '"healthy":1'
    #Check status in DCOS
    When I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    Then in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep marathonlb | grep R | wc -l' contains '1'
    When I run 'dcos task |  awk '{print $5}' | grep marathonlb' in the ssh connection and save the value in environment variable 'marathonlb-TaskId'
    Then in less than '1200' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonlb-TaskId} | grep TASK_RUNNING' contains 'TASK_RUNNING'
    And in less than '1200' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonlb-TaskId} | grep healthCheckResults' contains 'healthCheckResults'
    And in less than '1200' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonlb-TaskId} | grep  '"alive": true'' contains '"alive": true'
