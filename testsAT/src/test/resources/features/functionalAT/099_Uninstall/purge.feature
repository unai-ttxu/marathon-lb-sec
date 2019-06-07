@rest
Feature: Uninstalling marathon-lb-sec

  Scenario:[01] marathon-lb-sec can be uninstalled using cli
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    When I run 'dcos package uninstall --app-id=/marathonlb ${PACKAGE:-marathon-lb-sec}' in the ssh connection
    Then the command output contains 'Marathon-lb DC/OS Service has been uninstalled and will no longer run.'
    Then in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep ${PACKAGE:-marathon-lb-sec} | wc -l' contains '0'
