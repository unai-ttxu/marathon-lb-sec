@rest @dcos
@mandatory(BOOTSTRAP_IP,REMOTE_USER,PEM_FILE_PATH,DCOS_PASSWORD,DCOS_CLI_HOST,DCOS_CLI_USER,DCOS_CLI_PASSWORD)
Feature: [QATM-2113] Vault Renewal Token

  Scenario:[01] Check marathon-lb logs
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I run 'dcos task | grep marathon.*lb.* | tail -1 | awk '{print $5}'' in the ssh connection and save the value in environment variable 'TaskID'
    When in less than '300' seconds, checking each '10' seconds, the command output 'dcos task log --lines 10 !{TaskID} 2>/dev/null' contains 'INFO - 0 python marathon-lb.token_renewal.py {"@message": "Checking if token needs renewal"}'

  Scenario:[02] Change token period and check renewal
    Given I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    When I run 'sudo docker exec -it paas-bootstrap curl -k -H "X-Vault-Token:!{VAULT_TOKEN}" https://vault.service.!{EOS_INTERNAL_DOMAIN}:${EOS_VAULT_PORT:-8200}/v1/auth/approle/role/open -k -XPOST -d '{"period": 60}' | jq .' in the ssh connection
    And I wait '5' seconds
    Then in less than '300' seconds, checking each '10' seconds, the command output 'sudo docker exec -it paas-bootstrap curl -k -s -XGET -H 'X-Vault-Token:!{VAULT_TOKEN}' https://vault.service.!{EOS_INTERNAL_DOMAIN}:${EOS_VAULT_PORT:-8200}/v1/auth/approle/role/open | jq -rMc .data.period' contains '60'
    When I run 'sudo docker exec -it paas-bootstrap curl -k -H "X-Vault-Token:!{VAULT_TOKEN}" https://vault.service.!{EOS_INTERNAL_DOMAIN}:${EOS_VAULT_PORT:-8200}/v1/auth/approle/role/open -k -XPOST -d '{"period": 600}' | jq .' in the ssh connection
    And I wait '5' seconds
    Then in less than '300' seconds, checking each '10' seconds, the command output 'sudo docker exec -it paas-bootstrap curl -k -s -XGET -H 'X-Vault-Token:!{VAULT_TOKEN}' https://vault.service.!{EOS_INTERNAL_DOMAIN}:${EOS_VAULT_PORT:-8200}/v1/auth/approle/role/open | jq -rMc .data.period' contains '600'

  Scenario:[03] Check marathon-lb logs
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I run 'dcos task | grep marathon.*lb.* | tail -1 | awk '{print $5}'' in the ssh connection and save the value in environment variable 'TaskID'
    When in less than '300' seconds, checking each '10' seconds, the command output 'dcos task log --lines 10 !{TaskID} 2>/dev/null' contains 'INFO - 0 python marathon-lb.token_renewal.py {"@message": "Checking if token needs renewal"}'
