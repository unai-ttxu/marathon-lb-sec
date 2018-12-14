@rest
Feature: [QATM-1870] Service_Installation

  @skipOnEnv(ADVANCED_CONFIGURATION=TRUE)
  Scenario: [QATM-1870][01] Marathon-LB Simple Installation - Deploy service
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER:-admin}' with user '${REMOTE_USER:-operador}' and pem file 'src/test/resources/credentials/${PEM_FILE:-key.pem}'
    And I securely send requests to '${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}:443'
    # Obtain schema
    When I send a 'GET' request to '/service/deploy-api/deploy/marathon-lb/${FLAVOUR}/schema?level=1'
    Then I save element '$' in environment variable 'marathonlb-json-schema'
    And I run 'echo !{marathonlb-json-schema}' locally
    # Convert json
    And I convert jsonSchema '!{marathonlb-json-schema}' to json and save it in variable 'marathonlb-basic.json'
    And I run 'echo '!{marathonlb-basic.json}' > target/test-classes/schemas/marathonlb-basic.json' locally
    # Launch installation
    When I send a 'POST' request to '/service/deploy-api/deploy/marathon-lb/${FLAVOUR}/schema' based on 'schemas/marathonlb-basic.json' as 'json' with:
      |$.general.serviceId                           | UPDATE  | ${MARATHON-LB-ID:-marathon-lb-sec}                                     |n/a     |
    Then the service response status must be '202'
    And I run 'rm -f target/test-classes/schemas/cct/marathonlb-basic.json' locally

  @runOnEnv(ADVANCED_CONFIGURATION=TRUE)
  Scenario: [QATM-1870][01] Marathon-LB Advanced Installation - Deploy service
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER:-admin}' with user '${REMOTE_USER:-operador}' and pem file 'src/test/resources/credentials/${PEM_FILE:-key.pem}'
    And I securely send requests to '${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}:443'
    # Obtain schema
    When I send a 'GET' request to '/service/deploy-api/deploy/marathon-lb/${FLAVOUR}/schema?level=1'
    Then I save element '$' in environment variable 'marathonlb-json-schema'
    And I run 'echo !{marathonlb-json-schema}' locally
    # Convert json
    And I convert jsonSchema '!{marathonlb-json-schema}' to json and save it in variable 'marathonlb-advanced.json'
    And I run 'echo '!{marathonlb-advanced.json}' > target/test-classes/schemas/marathonlb-advanced.json' locally
    # Launch installation
    When I send a 'POST' request to '/service/deploy-api/deploy/marathon-lb/${FLAVOUR}/schema' based on 'schemas/marathonlb-advanced.json' as 'json' with:
      | $.marathon-lb.auto-assign-service-ports      | REPLACE | ${AUTO_ASSIGN_SERVICE_PORTS:-false}                                                                                                                                                                 | boolean |
      | $.marathon-lb.bind-http-https                | REPLACE | ${BIND_HTTP_HTTPS:-true}                                                                                                                                                                            | boolean |
      | $.marathon-lb.cpus                           | REPLACE | ${CPUS:-2}                                                                                                                                                                                          | number  |
      | $.marathon-lb.haproxy_global_default_options | UPDATE  | ${HAPROXY_GLOBAL_DEFAULT_OPTIONS:-redispatch,http-server-close,dontlognull}                                                                                                                         | n/a     |
      | $.marathon-lb.haproxy-group                  | UPDATE  | ${HAPROXY_GROUP:-external}                                                                                                                                                                          | n/a     |
      | $.marathon-lb.haproxy-map                    | REPLACE | ${HAPROXY_MAP:-true}                                                                                                                                                                                | boolean |
      | $.marathon-lb.instances                      | REPLACE | ${INSTANCES:-1}                                                                                                                                                                                     | number  |
      | $.marathon-lb.mem                            | REPLACE | ${MEM:-1024.0}                                                                                                                                                                                      | number  |
      | $.marathon-lb.minimumHealthCapacity          | REPLACE | ${MINIMUN_HEALTH_CAPACITY:-0.5}                                                                                                                                                                     | number  |
      | $.marathon-lb.maximumOverCapacity            | REPLACE | ${MAXIMUN_OVER_CAPACITY:-0.2}                                                                                                                                                                       | number  |
      | $.marathon-lb.name                           | UPDATE  | ${SERVICE:-marathon-lb-sec}                                                                                                                                                                         | n/a     |
      | $.marathon-lb.role                           | UPDATE  | ${ROLE:-slave_public}                                                                                                                                                                               | n/a     |
      | $.marathon-lb.strict-mode                    | REPLACE | ${STRICT_MODE:-false}                                                                                                                                                                               | boolean |
      | $.marathon-lb.sysctl-params                  | UPDATE  | ${SYSCTL_PARAMS:-net.ipv4.tcp_tw_reuse=1 net.ipv4.tcp_fin_timeout=30 net.ipv4.tcp_max_syn_backlog=10240 net.ipv4.tcp_max_tw_buckets=400000 net.ipv4.tcp_max_orphans=60000 net.core.somaxconn=10000} | n/a     |
      | $.marathon-lb.marathon-uri                   | UPDATE  | ${MARATHON_URI:-http://marathon.mesos:8080}                                                                                                                                                         | n/a     |
      | $.marathon-lb.vault_host                     | UPDATE  | ${VAULT_HOST:-vault.service.paas.labs.stratio.com}                                                                                                                                                  | n/a     |
      | $.marathon-lb.vault_port                     | REPLACE | ${VAULT_PORT:-8200}                                                                                                                                                                                 | number  |
      | $.marathon-lb.use_dynamic_authentication     | REPLACE | ${USE_DYNAMIC_AUTHENTICATION:-true}                                                                                                                                                                 | boolean |
      | $.marathon-lb.vault_token                    | UPDATE  | !{vaultToken}                                                                                                                                                                                       | n/a     |
      | $.marathon-lb.instance_app_role              | UPDATE  | ${INSTANCE_APP_ROLE:-open}                                                                                                                                                                          | n/a     |
    Then the service response status must be '202'
    And I run 'rm -f target/test-classes/schemas/cct/marathonlb-advanced.json' locally

  Scenario: [QATM-1870][02] Marathon-LB Installation - Status
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER:-admin}' with user '${REMOTE_USER:-operador}' and pem file 'src/test/resources/credentials/${PEM_FILE:-key.pem}'
    And I securely send requests to '${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}:443'
    #Check status in API
    When in less than '500' seconds, checking each '20' seconds, the command output 'curl -XGET -k -H "Cookie:dcos-acs-auth-cookie=!{DCOS_AUTH_COOKIE}" 'https://${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}/service/marathonlb/installer/status' | jq .healthy' contains '1'
    #Check status in DCOS
    When I open a ssh connection to '${DCOS_CLI_HOST}' with user 'root' and password 'stratio'
    Then in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep ${MARATHON-LB-ID:-marathon-lb-sec} | grep R | wc -l' contains '1'
    When I run 'dcos task |  awk '{print $5}' | grep ${MARATHON-LB-ID:-marathon-lb-sec}' in the ssh connection and save the value in environment variable 'marathonlb-TaskId'
    Then in less than '1200' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonlb-TaskId} | grep TASK_RUNNING' contains 'TASK_RUNNING'
    And in less than '1200' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonlb-TaskId} | grep healthCheckResults' contains 'healthCheckResults'
    And in less than '1200' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonlb-TaskId} | grep  '"alive": true'' contains '"alive": true'
