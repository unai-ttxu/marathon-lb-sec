@rest
Feature: [QATM-1870] Uninstall CCT
  Background: Setup DCOS-CLI
    #Start SSH with DCOS-CLI
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user 'root' and password 'stratio'

  @web
  Scenario: [QATM-1870][01] Retrieve cookie
    Given I set sso token using host '${CLUSTER_ID}.labs.stratio.com' with user 'admin' and password '1234'
    Given My app is running in '${CLUSTER_ID}.labs.stratio.com:443'

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
    Given I securely send requests to '${CLUSTER_ID}.labs.stratio.com:443'
    When I securely browse to '/service/deploy-api/swagger-ui.html#!/'
    Then I save selenium cookies in context
    And I save selenium dcos acs auth cookie in variable 'DCOS_AUTH_COOKIE'

  Scenario: [QATM-1870][04] Uninstall MarathonLB
    When  I run 'curl -X DELETE -k -H "Cookie:dcos-acs-auth-cookie=!{DCOS_AUTH_COOKIE}" https://${CLUSTER_ID}.labs.stratio.com/service/deploy-api/deploy/uninstall?app=${MARATHON-LB-ID:-marathon-lb-sec} -i' in the ssh connection with exit status '0' and save the value in environment variable 'result'
    #Check Uninstall in DCOS
    Then in less than '600' seconds, checking each '10' seconds, the command output 'dcos task | grep  ${MARATHON-LB-ID:-marathon-lb-sec} | wc -l' contains '0'
    #Check Uninstall in CCT-API
    When in less than '200' seconds, checking each '20' seconds, the command output 'curl -XGET -k -H "Cookie:dcos-acs-auth-cookie=!{DCOS_AUTH_COOKIE}" 'https://${CLUSTER_ID}.labs.stratio.com/service/deploy-api/deploy/status/all' |grep postgreseos | wc -l' contains '0'