@rest @dcos
@mandatory(BOOTSTRAP_IP,REMOTE_USER,PEM_FILE_PATH,DCOS_PASSWORD)
Feature: [QATM-2113] Certificates MarathonLB service

  Scenario:[01] Check Vault path by default
    Given I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    And I run 'sudo docker exec -t paas-bootstrap curl -X GET -fskL --tlsv1.2 -H "X-Vault-Token:!{VAULT_TOKEN}" "https://vault.service.!{EOS_INTERNAL_DOMAIN}:${EOS_VAULT_PORT:-8200}/v1/${VAULT_USERLAND_CERTIFICATE_BASE_PATH:-userland/certificates/}marathon-lb" | jq '.data."marathon-lb_crt"'' in the ssh connection with exit status '0'
    And I run 'sudo docker exec -t paas-bootstrap curl -X GET -fskL --tlsv1.2 -H "X-Vault-Token:!{VAULT_TOKEN}" "https://vault.service.!{EOS_INTERNAL_DOMAIN}:${EOS_VAULT_PORT:-8200}/v1/${VAULT_USERLAND_CERTIFICATE_BASE_PATH:-userland/certificates/}marathon-lb" | jq '.data."marathon-lb_key"'' in the ssh connection with exit status '0'
