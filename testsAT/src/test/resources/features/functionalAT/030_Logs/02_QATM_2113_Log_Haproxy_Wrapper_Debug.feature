@rest
@mandatory(DCOS_CLI_HOST,DCOS_CLI_USER,DCOS_CLI_PASSWORD)
Feature:[QATM-2113] Haproxy Wrapper logging debug

  Scenario:[01] Check marathon-lb logs
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I run 'dcos task | grep marathonlb | tail -1 | awk '{print $5}'' in the ssh connection and save the value in environment variable 'TaskID'
    When in less than '300' seconds, checking each '10' seconds, the command output 'dcos task log --lines 10000000 !{TaskID} 2>/dev/null | grep -e 'DEBUG.*haproxy_wrapper.*' | wc -l' contains '0'