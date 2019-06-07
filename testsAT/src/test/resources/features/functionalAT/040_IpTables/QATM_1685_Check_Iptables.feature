@rest
Feature: Check iptables in the node to avoid conflicts with Marathon-lb calico and minuteman

  Scenario:[01] Obtain node where marathon-lb-sec is running
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    When I run 'dcos task | grep marathonlb | awk '{print $2}'' in the ssh connection and save the value in environment variable 'publicHostIP'

  Scenario:[02] Check iptables Marathon-lb, Calico y Minuteman
    Given I open a ssh connection to '!{publicHostIP}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    And I run 'iptables -L | tail -10' in the ssh connection and save the value in environment variable 'iptablesInicial'
    And I outbound copy 'src/test/resources/scripts/iptables.sh' through a ssh connection to '/tmp'
    And I run 'chmod +x /tmp/iptables.sh' in the ssh connection
    And I run '/tmp/iptables.sh !{publicHostIP}' in the ssh connection
    And I run 'iptables -L | tail -10' in the ssh connection and save the value in environment variable 'iptablesFinal'
    Then '!{iptablesFinal}' is '!{iptablesInicial}'

