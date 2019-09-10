@rest
@mandatory(BOOTSTRAP_IP,REMOTE_USER,PEM_FILE_PATH,DCOS_IP,DCOS_TENANT,DCOS_PASSWORD)
Feature:[QATM-1870] Uninstall CCT

#  Scenario:[01] Obtain info from bootstrap
#    Given I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
#    Then I obtain basic information from bootstrap
#
  @include(feature:../010_Installation/001_installationCCT_IT.feature,scenario:[Setup][01] Prepare prerequisites)
  Scenario:[02] Uninstall MarathonLB
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '!{DCOS_USER}' with user '${REMOTE_USER}' and pem file '${PEM_FILE_PATH}' over SSH port '${EOS_NEW_SSH_PORT:-22}'
    Given I set sso token using host '!{EOS_ACCESS_POINT}' with user '!{DCOS_TENANT_USER}' and password '!{DCOS_TENANT_PASSWORD}' and tenant '!{CC_TENANT}'
    And I securely send requests to '!{EOS_ACCESS_POINT}:443'
    When I send a 'DELETE' request to '/service/deploy-api/deploy/uninstall?app=marathonlb'
    And in less than '200' seconds, checking each '20' seconds, I send a 'GET' request to '/service/deploy-api/deploy/status/all' so that the response does not contains 'marathonlb'