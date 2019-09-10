@rest
@mandatory(BOOTSTRAP_IP,REMOTE_USER,PEM_FILE_PATH,EOS_VAULT_PORT)
Feature: [QATM-2113] Certificates MarathonLB service

  Background:[Setup] Obtain info from bootstrap
    Then I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I obtain basic information from bootstrap

  Scenario:[02] Check Vault path by default
    Given I run 'curl -X GET -fskL --tlsv1.2 -H "X-Vault-Token:!{VAULT_TOKEN}" "https://!{EOS_VAULT_HOST}:${EOS_VAULT_PORT}/v1/${VAULT_USERLAND_CERTIFICATE_BASE_PATH:-userland/certificates/}marathon-lb" | jq '.data."marathon-lb_crt"'' locally with exit status '0'
    And I run 'curl -X GET -fskL --tlsv1.2 -H "X-Vault-Token:!{VAULT_TOKEN}" "https://!{EOS_VAULT_HOST}:${EOS_VAULT_PORT}/v1/${VAULT_USERLAND_CERTIFICATE_BASE_PATH:-userland/certificates/}marathon-lb" | jq '.data."marathon-lb_key"'' locally with exit status '0'
