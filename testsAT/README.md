# README

## ACCEPTANCE TESTS

Cucumber automated acceptance tests.
This module depends on a QA library (stratio-test-bdd), where common logic and steps are implemented.

## EXECUTION TEST

These tests will be executed as part of the continuous integration flow as follows:

`mvn verify [-D<ENV_VAR>=<VALUE>] [-Dit.test=<TEST_TO_EXECUTE>|-Dgroups=<GROUP_TO_EXECUTE>]`

## TESTS

1. [Nightly](#nightly)
2. [Check Invalid App Certificates](#check-invalid-app-certificates)
3. [Centralized Logs](#centralized-logs)
4. [Log HAProxy Wrapper Debug](#log-haproxy-wrapper-debug)
5. [Vault Renewal Token](#vault-renewal-token)
6. [Certs MarathonLB Serv](#certs-marathonlb-serv)
7. [Certificates](#certificates)

### Nightly
- Pre-requisites:
    - N/A
- Description:
    - A marathonLB service is installed using the flavour passed as a parameter.
    - All checks executed during Nightly to make sure service is working fine.
- Needed:
    - DCOS_IP: IP from the cluster
    - BOOTSTRAP_IP: IP from the bootstrap
    - DCOS_PASSWORD: DCOS cluster password
    - DCOS_CLI_HOST: name/IP of the dcos-cli docker container
    - DCOS_CLI_USER: dcos-cli docker user
    - DCOS_CLI_PASSWORD: dcos-cli docker password
    - REMOTE_USER: operational user for cluster machines
    - PEM_FILE_PATH: local path to pem file for cluster machines
    - EOS_INSTALLER_VERSION: EOS version
- Usage example:
    `mvn clean verify -Dgroups=nightly -DBOOTSTRAP_IP=XXX.XXX.XXX.XXX -DREMOTE_USER=remote_user -DPEM_FILE_PATH=<file_path_key> -DDCOS_CLI_HOST=XXX.XXX.XXX.XXX -DDCOS_CLI_USER=user -DDCOS_CLI_PASSWORD=password -DEOS_INSTALLER_VERSION=<EOS Version> -DDCOS_PASSWORD=password -DlogLevel=DEBUG`

### Check Invalid App Certificates
- Pre-requisites:
    - A marathonLB service must be installed.
- Description:
    - Some checks are run to make sure it has been installed correctly.
- Needed:
    - DCOS_CLI_HOST: name/IP of the dcos-cli docker container
    - DCOS_CLI_USER: dcos-cli docker user
    - DCOS_CLI_PASSWORD: dcos-cli docker password
    - BOOTSTRAP_IP: IP from the bootstrap
    - REMOTE_USER: operational user for cluster machines
    - PEM_FILE_PATH: local path to pem file for cluster machines
    - EOS_INSTALLER_VERSION: EOS version
    - DCOS_PASSWORD: DCOS cluster password
- Usage example:
    `mvn clean verify -Dgroups=checkInvalidAppCerts -DDCOS_CLI_HOST=XXX.XXX.XXX.XXX -DDCOS_CLI_USER=user -DDCOS_CLI_PASSWORD=password -DREMOTE_USER=remote_user -DPEM_FILE_PATH=<file_path_key> -DlogLevel=DEBUG -DBOOTSTRAP_IP=XXX.XXX.XXX.XXX -DEOS_INSTALLER_VERSION=<EOS_Version> -DDCOS_PASSWORD=password`

### Centralized Logs
- Pre-requisites:
    - A marathonLB service must be installed.
- Description:
    - Some checks are run to make sure it has been installed correctly.
- Needed:
    - DCOS_CLI_HOST: name/IP of the dcos-cli docker container
    - DCOS_CLI_USER: dcos-cli docker user
    - DCOS_CLI_PASSWORD: dcos-cli docker password
    - BOOTSTRAP_IP: IP from the bootstrap
    - REMOTE_USER: operational user for cluster machines
    - PEM_FILE_PATH: local path to pem file for cluster machines
    - DCOS_PASSWORD: DCOS cluster password
- Usage example: 
    `mvn clean verify -Dgroups=centralizedlogs -DDCOS_CLI_HOST=XXX.XXX.XXX.XXX -DDCOS_CLI_USER=user -DDCOS_CLI_PASSWORD=password -DREMOTE_USER=remote_user -DPEM_FILE_PATH=<file_path_key> -DlogLevel=DEBUG -DBOOTSTRAP_IP=XXX.XXX.XXX.XXX -DDCOS_PASSWORD=password`

### Log HAProxy Wrapper Debug
- Pre-requisites:
    - A marathonLB service must be installed.
- Description:
    - Some checks are run to make sure it has been installed correctly.
- Needed:
    - DCOS_CLI_HOST: name/IP of the dcos-cli docker container
    - DCOS_CLI_USER: dcos-cli docker user
    - DCOS_CLI_PASSWORD: dcos-cli docker password
- Usage example: 
    `mvn clean verify -Dgroups=haproxyWrapperDebug -DDCOS_CLI_HOST=XXX.XXX.XXX.XXX -DDCOS_CLI_USER=user -DDCOS_CLI_PASSWORD=password`

### Vault Renewal Token
- Pre-requisites:
    - A marathonLB service must be installed.
- Description:
    - Some checks are run to make sure it has been installed correctly.
- Needed:
    - DCOS_CLI_HOST: name/IP of the dcos-cli docker container
    - DCOS_CLI_USER: dcos-cli docker user
    - DCOS_CLI_PASSWORD: dcos-cli docker password
    - BOOTSTRAP_IP: IP from the bootstrap
    - REMOTE_USER: operational user for cluster machines
    - PEM_FILE_PATH: local path to pem file for cluster machines
    - DCOS_PASSWORD: DCOS cluster password
- Optional:    
    - EOS_VAULT_PORT: vault port (default: 8200)
- Usage example: 
    `mvn clean verify -Dgroups=vaultRenewalToken -DDCOS_CLI_HOST=XXX.XXX.XXX.XXX -DDCOS_CLI_USER=user -DDCOS_CLI_PASSWORD=password -DBOOTSTRAP_IP=XXX.XXX.XXX.XXX -DREMOTE_USER=remote_user -DPEM_FILE_PATH=<file_path_key> -DDCOS_PASSWORD=password`

### Certs MarathonLB Serv
- Pre-requisites:
    - A marathonLB service must be installed.
- Description:
    - Some checks are run to make sure it has been installed correctly.
- Needed:
    - BOOTSTRAP_IP: IP from the bootstrap
    - REMOTE_USER: operational user for cluster machines
    - PEM_FILE_PATH: local path to pem file for cluster machines
    - DCOS_PASSWORD: DCOS cluster password
- Optional:    
    - EOS_VAULT_PORT: vault port (default: 8200)
- Usage example: 
    `mvn clean verify -Dgroups=certsMarathonLBServ -DBOOTSTRAP_IP=XXX.XXX.XXX.XXX -DREMOTE_USER=remote_user -DPEM_FILE_PATH=<file_path_key> -DlogLevel=DEBUG -DDCOS_PASSWORD=password`

### Certificates
- Pre-requisites:
    - A marathonLB service must be installed.
- Description:
    - Some checks are run to make sure it has been installed correctly.
- Needed:
    - BOOTSTRAP_IP: IP from the bootstrap
    - REMOTE_USER: operational user for cluster machines
    - PEM_FILE_PATH: local path to pem file for cluster machines
    - DCOS_CLI_HOST: name/IP of the dcos-cli docker container
    - DCOS_CLI_USER: dcos-cli docker user
    - DCOS_CLI_PASSWORD: dcos-cli docker password
    - EOS_INSTALLER_VERSION: EOS version
    - DCOS_PASSWORD: DCOS cluster password
- Usage example: 
    `mvn clean verify -Dgroups=app_client_certificates -DBOOTSTRAP_IP=XXX.XXX.XXX.XXX -DREMOTE_USER=remote_user -DPEM_FILE_PATH=<file_path_key> -DDCOS_CLI_HOST=XXX.XXX.XXX.XXX -DDCOS_CLI_USER=user -DDCOS_CLI_PASSWORD=password -DEOS_INSTALLER_VERSION=<EOS_Version> -DlogLevel=DEBUG -DDCOS_PASSWORD=password`