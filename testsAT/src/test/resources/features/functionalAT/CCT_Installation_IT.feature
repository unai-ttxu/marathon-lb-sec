@rest
Feature: [QATM-1870] Service_Installation
  Background: Setup DCOS-CLI
    #Start SSH with DCOS-CLI
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user 'root' and password 'stratio'

  Scenario: [QATM-1870][01] Marathon-LB Installation - Retrive token of enviroment
    When I open a ssh connection to '${BOOTSTRAP_IP}' with user '${ROOT_USER:-root}' and password '${ROOT_PASSWORD:-stratio}'
    When I run 'cat /stratio_volume/vault_response |jq '.root_token'| tr -d "\""' in the ssh connection and save the value in environment variable 'root_token'
    Then  I run 'echo !{root_token}' in the ssh connection

  @web
  Scenario: [QATM-1870][02] Marathon-LB Installation -Retrieve cookies
    Given I set sso token using host '${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}' with user 'admin' and password '1234'
    Given My app is running in '${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}:443'
    #Login into the platform
    When I securely browse to '#/login'
    And I wait '5' seconds
    When '1' elements exists with 'id:oauth-iframe'
    And I switch to the iframe on index '0'
    And '1' elements exists with 'xpath://*[@id="username"]'
    And I type 'admin' on the element on index '0'
    And '1' elements exists with 'xpath://*[@id="password"]'
    And I type '1234' on the element on index '0'
    And '1' elements exists with 'id:login-button'
    And I click on the element on index '0'
    And I wait '5' seconds
    Given I securely send requests to '${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}:443'
    When I securely browse to '/service/deploy-api/swagger-ui.html#!/'
    Then I save selenium cookies in context
    And I save selenium dcos acs auth cookie in variable 'DCOS_AUTH_COOKIE'
    Then  I run 'echo !{DCOS_AUTH_COOKIE}' locally

  Scenario: [QATM-1870][03] Marathon-LB Installation - Get versions installed in Command Center
    Given I run 'curl -s -XGET -k -H "Cookie:dcos-acs-auth-cookie=!{DCOS_AUTH_COOKIE}" -H 'Content-Type: application/json' -H 'Accept: application/json' https://${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}/service/deploy-api/universe/marathon-lb | awk 'FNR == 1'| tr -d "\"" | tr -d []' in the ssh connection and save the value in environment variable 'relese_name'
    When I run 'echo !{relese_name}' in the ssh connection
    #Retrive relese version number

  @skipOnEnv(ADVANCED_CONFIGURATION=TRUE)
  Scenario: [QATM-1870][04] Marathon-LB Simple Installation - Deploy service
    #Retrieve Json-Schema
    Given I run 'curl -XGET -k -H "Cookie:dcos-acs-auth-cookie=!{DCOS_AUTH_COOKIE}" -H 'Content-Type: application/json' -H 'Accept: application/json' https://${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}/service/deploy-api/deploy/marathon-lb/!{relese_name}/schema?level=1' in the ssh connection and save the value in environment variable 'marathonlb-json-schema'
    When I convert jsonSchema '!{marathonlb-json-schema}' to json and save it in variable 'marathonlb-basic.json'
    Then  I run 'echo '!{marathonlb-basic.json}' > target/test-classes/schemas/cct/marathonlb-basic.json' locally
    Given I create file 'marathonlb-with-variables.json' based on 'schemas/marathon-lb-sec-config.json' as 'json' with:
      |$.general.serviceId                           | UPDATE  | ${MARATHON-LB-ID:-marathon-lb-sec}                                                                                                               |n/a     |
    When I outbound copy 'target/test-classes/marathonlb-with-variables.json' through a ssh connection to '/tmp'
    Given I run 'cat /tmp/marathonlb-with-variables.json' in the ssh connection and save the value in environment variable 'marathonlb'
    And I run 'rm -f /tmp/marathonlb-with-variables.json' in the ssh connection
    #Install MarathonLB
    Given I run 'curl -XPOST -k -H "Cookie:dcos-acs-auth-cookie=!{DCOS_AUTH_COOKIE}" -H 'Content-Type: application/json' -H 'Accep  t: application/json' -d '!{marathonlb}' https://${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}/service/deploy-api/deploy/marathon-lb/!{relese_name}/schema -i' in the ssh connection with exit status '0'
    #Remove files
    Then  I run 'echo '!{marathonlb-basic.json}' > src/test/resources/schemas/cct/marathonlb-basic.json' locally
    And I run 'rm -f target/test-classes/schemas/cct/marathonlb-basic.json' locally

  @runOnEnv(ADVANCED_CONFIGURATION=TRUE)
  Scenario: [QATM-1870][04] Marathon-LB Advanced Installation - Deploy service
    #Retrieve Json-Schema
    Given I run 'curl -XGET -k -H "Cookie:dcos-acs-auth-cookie=!{DCOS_AUTH_COOKIE}" -H 'Content-Type: application/json' -H 'Accept: application/json' https://${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}/service/deploy-api/deploy/marathon-lb/!{relese_name}/schema?level=1' in the ssh connection and save the value in environment variable 'marathonlb-json-schema'
    When I convert jsonSchema '!{marathonlb-json-schema}' to json and save it in variable 'marathonlb-basic.json'
    Then  I run 'echo '!{marathonlb-basic.json}' > target/test-classes/schemas/cct/marathonlb-basic.json' locally
    Given I create file 'marathonlb-with-variables.json' based on 'schemas/marathon-lb-sec-config.json' as 'json' with:
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
    When I outbound copy 'target/test-classes/marathonlb-with-variables.json' through a ssh connection to '/tmp'
    Given I run 'cat /tmp/marathonlb-with-variables.json' in the ssh connection and save the value in environment variable 'marathonlb'
    And I run 'rm -f /tmp/marathonlb-with-variables.json' in the ssh connection
    #Install MarathonLB
    Given I run 'curl -XPOST -k -H "Cookie:dcos-acs-auth-cookie=!{DCOS_AUTH_COOKIE}" -H 'Content-Type: application/json' -H 'Accep  t: application/json' -d '!{marathonlb}' https://${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}/service/deploy-api/deploy/marathon-lb/!{relese_name}/schema -i' in the ssh connection with exit status '0'
    #Remove files
    Then  I run 'echo '!{marathonlb-basic.json}' > src/test/resources/schemas/cct/marathonlb-basic.json' locally
    And I run 'rm -f target/test-classes/schemas/cct/marathonlb-basic.json' locally


  Scenario: [QATM-1870][05] Marathon-LB Installation - Status
    #Check status in API
    When in less than '500' seconds, checking each '20' seconds, the command output 'curl -XGET -k -H "Cookie:dcos-acs-auth-cookie=!{DCOS_AUTH_COOKIE}" 'https://${CLUSTER_ID}.${CLUSTER_DOMAIN:-labs.stratio.com}/service/marathonlb/installer/status' | jq .healthy' contains '1'
    #Check status in DCOS
    When I open a ssh connection to '${DCOS_CLI_HOST}' with user 'root' and password 'stratio'
    Then in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep ${MARATHON-LB-ID:-marathon-lb-sec} | grep R | wc -l' contains '1'
    When I run 'dcos task |  awk '{print $5}' | grep ${MARATHON-LB-ID:-marathon-lb-sec}' in the ssh connection and save the value in environment variable 'marathonlb-TaskId'
    Then in less than '1200' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonlb-TaskId} | grep TASK_RUNNING' contains 'TASK_RUNNING'
    And in less than '1200' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonlb-TaskId} | grep healthCheckResults' contains 'healthCheckResults'
    And in less than '1200' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonlb-TaskId} | grep  '"alive": true'' contains '"alive": true'
