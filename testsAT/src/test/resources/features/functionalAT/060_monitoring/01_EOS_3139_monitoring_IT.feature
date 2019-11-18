@rest
@mandatory(BOOTSTRAP_IP,REMOTE_USER,PEM_FILE_PATH,DCOS_TENANT,DCOS_PASSWORD,EOS_MONITOR_CLUSTER,UNIVERSE_MARATHONLB_VERSION,EOS_PUBLIC_AGENTS_LIST,DCOS_CLI_HOST,DCOS_CLI_USER,DCOS_CLI_PASSWORD)
Feature: Check multiple deployments which share vhost

  @runOnEnv(EOS_MONITOR_CLUSTER=yes)
  Scenario:[01] Obtain info from bootstrap
    Given I open a ssh connection to '${BOOTSTRAP_IP}' in port '${EOS_NEW_SSH_PORT:-22}' with user '${REMOTE_USER}' using pem file '${PEM_FILE_PATH}'
    Then I obtain basic information from bootstrap

  @runOnEnv(EOS_MONITOR_CLUSTER=yes)
  Scenario:[01] Check monitoring solution is installed
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${DCOS_CLI_USER}' and password '${DCOS_CLI_PASSWORD}'
    And I run 'dcos task | grep grafana-eos.* | grep R' in the ssh connection
    And I run 'dcos task | grep prometheus-eos.* | grep R' in the ssh connection
    And I run 'dcos task | grep marathon-exporter.* | grep R' in the ssh connection
    And I run 'dcos marathon task list | grep .*/grafana-eos | awk '{print $5}'' in the ssh connection and save the value in environment variable 'grafanaTaskId'
    And I run 'dcos marathon task list | grep .*/prometheus-eos | awk '{print $5}'' in the ssh connection and save the value in environment variable 'prometheusTaskId'
    And I run 'dcos marathon task list | grep .*/marathon-exporter | awk '{print $5}'' in the ssh connection and save the value in environment variable 'marathonExporterTaskId'
    And I run 'dcos marathon app show grafana-eos | jq -r .networks[].name | grep -w metrics' in the ssh connection
    And I run 'dcos marathon app show prometheus-eos | jq -r .networks[].name | grep -w metrics' in the ssh connection
    And I run 'dcos marathon app show marathon-exporter | jq -r .networks[].name | grep -w metrics' in the ssh connection
    And I run 'dcos marathon task show !{grafanaTaskId} | grep -A50 healthCheckResults | grep -A50 '"alive": true' | grep '"state": "TASK_RUNNING"'' in the ssh connection
    And I run 'dcos marathon task show !{prometheusTaskId} | grep -A50 healthCheckResults | grep -A50 '"alive": true' | grep '"state": "TASK_RUNNING"'' in the ssh connection
    And I run 'dcos marathon task show !{prometheusTaskId} | jq -r .ipAddresses[].ipAddress' in the ssh connection and save the value in environment variable 'prometheusCalicoIP'
    And I run 'dcos marathon task show !{marathonExporterTaskId} | grep -A50 healthCheckResults | grep -A50 '"alive": true' | grep '"state": "TASK_RUNNING"'' in the ssh connection
    And I run 'dcos marathon task show !{marathonExporterTaskId} | jq -r .ipAddresses[].ipAddress' in the ssh connection and save the value in environment variable 'marathonExporterCalicoIP'

  @runOnEnv(UNIVERSE_MARATHONLB_VERSION>0.6.0||UNIVERSE_MARATHONLB_VERSION=0.6.0)
  @runOnEnv(EOS_MONITOR_CLUSTER=yes)
  @loop(EOS_PUBLIC_AGENTS_LIST,PUBLIC_IP)
  Scenario:[02] Check exporter in Prometheus-EOS
    Given I securely send requests to '!{EOS_ACCESS_POINT}'
    And I set sso token using host '!{EOS_ACCESS_POINT}' with user '!{DCOS_USER}' and password '${DCOS_PASSWORD}' and tenant '${DCOS_TENANT}'
    When I send a 'GET' request to '/service/prometheus-eos/api/v1/targets'
    Then the service response status must be '200'
    And I save element '$' in environment variable 'exporters'
    And I run 'echo '!{exporters}' | jq '.data.activeTargets[] | select(.discoveredLabels.job=="services" and .health=="up" and .scrapeUrl=="http://'<PUBLIC_IP>':9090/metrics" and .discoveredLabels.name=="marathonlb" and .discoveredLabels.task_id=="marathonlb" and .labels.name=="marathonlb" and .labels.task_id=="marathonlb")'' locally