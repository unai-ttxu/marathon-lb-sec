@rest
Feature: [QATM-2113] Vault Renewal Token

  Scenario:[01] Obtain info from bootstrap
    Given I open a ssh connection to '${BOOTSTRAP_IP}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I obtain basic information from bootstrap

  Scenario:[02] Check marathon-lb logs
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I run 'dcos task | grep marathonlb | tail -1 | awk '{print $5}'' in the ssh connection and save the value in environment variable 'TaskID'
    When in less than '300' seconds, checking each '10' seconds, the command output 'dcos task log --lines 10 !{TaskID} 2>/dev/null' contains 'INFO - 0 python marathon-lb.token_renewal.py {"@message": "Checking if token needs renewal"}'

  Scenario:[03] Change token period and check renewal
    Given I open a ssh connection to '${BOOTSTRAP_IP}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    When I run 'sudo docker exec -it paas-bootstrap curl -k -H "X-Vault-Token:!{VAULT_TOKEN}" https://!{EOS_VAULT_HOST}:${EOS_VAULT_PORT}/v1/auth/approle/role/open -k -XPOST -d '{"period": 60}' | jq .' in the ssh connection
    And I wait '5' seconds
    Then in less than '300' seconds, checking each '10' seconds, the command output 'sudo docker exec -it paas-bootstrap curl -k -s -XGET -H 'X-Vault-Token:!{VAULT_TOKEN}' https://!{EOS_VAULT_HOST}:${EOS_VAULT_PORT}/v1/auth/approle/role/open | jq -rMc .data.period' contains '60'
    When I run 'sudo docker exec -it paas-bootstrap curl -k -H "X-Vault-Token:!{VAULT_TOKEN}" https://!{EOS_VAULT_HOST}:${EOS_VAULT_PORT}/v1/auth/approle/role/open -k -XPOST -d '{"period": 600}' | jq .' in the ssh connection
    And I wait '5' seconds
    Then in less than '300' seconds, checking each '10' seconds, the command output 'sudo docker exec -it paas-bootstrap curl -k -s -XGET -H 'X-Vault-Token:!{VAULT_TOKEN}' https://!{EOS_VAULT_HOST}:${EOS_VAULT_PORT}/v1/auth/approle/role/open | jq -rMc .data.period' contains '600'

  Scenario:[04] Check marathon-lb logs
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I run 'dcos task | grep marathonlb | tail -1 | awk '{print $5}'' in the ssh connection and save the value in environment variable 'TaskID'
    When in less than '300' seconds, checking each '10' seconds, the command output 'dcos task log --lines 10 !{TaskID} 2>/dev/null' contains 'INFO - 0 python marathon-lb.token_renewal.py {"@message": "Checking if token needs renewal"}'
