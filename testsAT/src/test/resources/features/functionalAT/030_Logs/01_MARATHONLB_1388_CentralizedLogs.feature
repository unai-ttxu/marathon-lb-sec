@rest
@mandatory(DCOS_CLI_HOST,DCOS_CLI_USER,DCOS_CLI_PASSWORD)
Feature:[MARATHONLB-1388] Centralized logs

  Background:[Setup] Get MarathonLB task id
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    When I run 'dcos task | grep marathon.*lb.* | tail -1 | awk '{print $5}'' in the ssh connection and save the value in environment variable 'TaskID'

  Scenario:[01] Check marathon-lb logs format
    And I run 'expr `dcos task log --lines 10000 !{TaskID} 2>&1 | wc -l` \* 5 / 100' in the ssh connection and save the value in environment variable 'totalLinesThreshold'
    And I run 'export LANG=en_US.UTF-8 && dcos task log --lines 10000 !{TaskID} 2>&1 | grep -P "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}((.|,)\d{3})?((\+|-)\d{2}:?\d{2}|Z) (FATAL|ERROR|WARN|WARNING|NOTICE|INFO|DEBUG|TRACE|AUDIT) (-|\w+) (-|0|1) ([0-9A-Za-z\/\.\-_\$:]+) ([0-9A-Za-z\/\.\-_\$:-\[\]]+)(:\d+)? .*$" | wc -l' in the ssh connection and save the value in environment variable 'formatedLines'
    Then '!{formatedLines}' is higher than '!{totalLinesThreshold}'

  Scenario:[02] Check stdout/stderr is logged correctly
    And I run 'export LANG=en_US.UTF-8 && dcos task log --lines 10000 !{TaskID} stdout 2>&1 | grep -e "\(INFO\|WARN\|DEBUG\|TRACE\)" | wc -l' in the ssh connection and save the value in environment variable 'StdoutFormatedLines'
    And '!{StdoutFormatedLines}' is higher than '0'
    And I run 'export LANG=en_US.UTF-8 && dcos task log --lines 10000 !{TaskID} stderr 2>&1 | grep -v "\(INFO\|WARN\|DEBUG\|TRACE\)" | wc -l' in the ssh connection and save the value in environment variable 'StderrFormatedLines'
    Then '!{StderrFormatedLines}' is higher than '0'

  Scenario:[03] Check marathonLb stdout/stderr is logged correctly
    When I run 'export LANG=en_US.UTF-8 && dcos task log --lines 10000 !{TaskID} | grep VAULT_TOKEN' in the ssh connection with exit status '1'
