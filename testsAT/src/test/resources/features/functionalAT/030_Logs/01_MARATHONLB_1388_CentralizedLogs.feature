@rest
Feature:[MARATHONLB-1388] Centralized logs

  Scenario:[01] Check marathon-lb logs format
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    When I run 'dcos task | grep marathonlb | tail -1 | awk '{print $5}'' in the ssh connection and save the value in environment variable 'TaskID'
    And I run 'expr `dcos task log --lines 10000 !{TaskID} 2>/dev/null | wc -l` \* 5 / 100' in the ssh connection and save the value in environment variable 'totalLinesThreshold'
    And I run 'dcos task log --lines 10000 !{TaskID} 2>/dev/null | grep -e "^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9]\{3\}[+-][0-9]\{2\}:[0-9]\{2\} \(INFO\|ERROR\|WARN\|DEBUG\|TRACE\) .* .* .* .* .*$" | wc -l' in the ssh connection and save the value in environment variable 'formatedLines'
    Then '!{formatedLines}' is higher than '!{totalLinesThreshold}'

  Scenario:[02] Check stdout/stderr is logged correctly
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    When I run 'dcos task | grep marathonlb | tail -1 | awk '{print $5}'' in the ssh connection and save the value in environment variable 'TaskID'
    And I run 'dcos task log --lines 10000 !{TaskID} stdout 2>/dev/null | grep -e "\(INFO\|WARN\|DEBUG\|TRACE\)" | wc -l' in the ssh connection and save the value in environment variable 'StdoutFormatedLines'
    And '!{StdoutFormatedLines}' is higher than '0'
    And I run 'dcos task log --lines 10000 !{TaskID} stderr 2>/dev/null | grep -v "\(INFO\|WARN\|DEBUG\|TRACE\)" | wc -l' in the ssh connection and save the value in environment variable 'StderrFormatedLines'
    Then '!{StderrFormatedLines}' is higher than '0'

