@rest
@mandatory(DCOS_CLI_HOST,DCOS_CLI_USER,DCOS_CLI_PASSWORD,BOOTSTRAP_IP,REMOTE_USER,PEM_FILE_PATH,DCOS_IP,DCOS_TENANT,DCOS_PASSWORD)
Feature: Check multiple deployments which share vhost

  Scenario:[01] Obtain info from bootstrap
    Given I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I obtain basic information from bootstrap

  Scenario Outline:[02] Deploy different services nginx
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '!{DCOS_USER}' with user '${REMOTE_USER}' and pem file '${PEM_FILE_PATH}' over SSH port '${EOS_NEW_SSH_PORT:-22}'
    And I securely send requests to '!{EOS_ACCESS_POINT}:443'
    When I create file '<id>-config.json' based on 'schemas/nginx-qa-config.json' as 'json' with:
      | $.id                                | REPLACE | <id>          | string |
      | $.labels.HAPROXY_0_VHOST            | REPLACE | <vhost>       | string |
      | $.labels.HAPROXY_0_PATH             | REPLACE | <path>        | string |
      | $.labels.HAPROXY_0_BACKEND_WEIGHT   | REPLACE | <weight>      | string |
      | $.labels.DCOS_PACKAGE_NAME          | REPLACE | <id>          | string |
      | $.labels.DCOS_SERVICE_NAME          | REPLACE | <id>          | string |
      | $.container.docker.image            | UPDATE | ${EOS_EXTERNAL_DOCKER_REGISTRY:-qa.stratio.com}/nginx:1.10.3-alpine | n/a |
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I outbound copy 'target/test-classes/<id>-config.json' through a ssh connection to '/tmp'
    And I run 'dcos marathon app add /tmp/<id>-config.json' in the ssh connection
    And I run 'rm -f /tmp/<id>-config.json' in the ssh connection
    Examples:
      | id                   | vhost                      | path      | weight  |
      | nginx-qa-testqa      | nginx-qa.labs.stratio.com  |           | 0       |
      | nginx-qa-testqa1     | nginx-qa.labs.stratio.com  | testqa1   | 1       |
      | nginx-qa-testqa2     | nginx-qa.labs.stratio.com  | testqa2   | 2       |
      | nginx-qa-testqa3     | nginx-qa.labs.stratio.com  | testqa3   | 3       |

  Scenario Outline:[03] Check deployment for different services nginx
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I run 'dcos task | grep -w '<id>' | awk '{print $4}' | grep R' in the ssh connection with exit status '0'
    And I run 'dcos marathon task list | grep -w /'<id>' | grep True | awk '{print $5}'' in the ssh connection with exit status '0' and save the value in environment variable 'nginxTaskId'
    And I run 'dcos marathon task show !{nginxTaskId} | jq 'select(.state=="TASK_RUNNING" and .healthCheckResults[].alive==true)'' in the ssh connection with exit status '0'
    Examples:
      | id                   |
      | nginx-qa-testqa      |
      | nginx-qa-testqa1     |
      | nginx-qa-testqa2     |
      | nginx-qa-testqa3     |

  @include(feature:../010_Installation/001_installationCCT_IT.feature,scenario:[Setup][01] Prepare prerequisites)
  @include(feature:../010_Installation/001_installationCCT_IT.feature,scenario:[03] Obtain node where marathon-lb-sec is running)
  Scenario:[04] Check rules in MarathonLB
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I run 'curl -XGET http://!{publicHostIP}:9090/_haproxy_getconfig' in the ssh connection with exit status '0' and save the value in environment variable 'haproxy_getConfig'
    And I run 'echo '!{haproxy_getConfig}' | grep -A12 'frontend marathon_http_in' > /tmp/rules.txt' locally
    And I run 'diff target/test-classes/schemas/marathonlb_http_rules.txt /tmp/rules.txt' locally with exit status '0'
    And I run 'echo '!{haproxy_getConfig}' | grep -A9 'frontend marathon_https_in' > /tmp/rules.txt' locally
    And I run 'diff target/test-classes/schemas/marathonlb_https_rules.txt /tmp/rules.txt' locally with exit status '0'
    And I run 'rm -f /tmp/rules.txt' locally

  Scenario Outline:[03] Check deployment for different services nginx
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I run 'dcos marathon app remove <id>' in the ssh connection
    And I run 'dcos task | grep -w '<id>' | awk '{print $4}' | grep R' in the ssh connection with exit status '1'
    Examples:
      | id                   |
      | nginx-qa-testqa      |
      | nginx-qa-testqa1     |
      | nginx-qa-testqa2     |
      | nginx-qa-testqa3     |








