import common
import json
import logging
import os
import subprocess
import time

head_vault_hosts = 'OLD_IFS=${IFS};IFS=\',\' read -r -a VAULT_HOSTS <<< \"$STRING_VAULT_HOST\";IFS=${OLD_IFS};'
source_kms_utils = '. /usr/sbin/kms_utils.sh;'

global vault_token
global vault_accessor
global MAX_PERCENTAGE_EXPIRATION

vault_token = os.getenv('VAULT_TOKEN', '')
vault_accessor = os.getenv('ACCESSOR_TOKEN','')
MIN_PERCENTAGE_EXPIRATION = 0.2

logger = None
def init_log():
    global logger
    logger = common.marathon_lb_logger.getChild('kms_utils.py')

def login():
  global vault_token
  global vault_accessor
  resp,_ = exec_with_kms_utils('', 'login', 'echo "{\\\"vaulttoken\\\": \\\"$VAULT_TOKEN\\\",\\\"accessor\\\": \\\"$ACCESSOR_TOKEN\\\"}"')
  jsonVal = json.loads(resp.decode("utf-8"))
  vault_accessor = (jsonVal['accessor'])
  vault_token = (jsonVal['vaulttoken'])

def get_cert(cluster, instance, fqdn, o_format, store_path):
  variables = ''.join(['export VAULT_TOKEN=', vault_token, ';'])
  command = ' '.join(['getCert', cluster, instance, fqdn, o_format, store_path]) 
  resp,returncode = exec_with_kms_utils(variables, command , '')
  logger.debug('get_cert for ' + instance + ' returned ' + str(returncode) + ' and ' + resp.decode("utf-8"))
  
  return returncode == 0

def get_token_info():
  variables = ''.join(['export VAULT_TOKEN=', vault_token, ';', 'export ACCESSOR_TOKEN=', vault_accessor, ';'])
  command = 'token_info'
  resp,_ = exec_with_kms_utils(variables, command, '')
  respArr = resp.decode("utf-8").split(',')
  jsonValue = json.loads(','.join(respArr[1:]))
  logger.debug('status ' + respArr[0])
  logger.debug(jsonValue)
  
  return jsonValue

def check_token_needs_renewal(force):
  jsonInfo = get_token_info()
  creationTime = jsonInfo['data']['creation_time']
  
  #Convert time as given from Vault to epoch time
  expire_time_vault = jsonInfo['data']['expire_time']
  expire_time_string = expire_time_vault.split('T')[0] + ' ' + expire_time_vault.split('T')[1].split('.')[0]
  expire_time_tuple = time.strptime(expire_time_string, '%Y-%m-%d %H:%M:%S')
  expire_time = time.mktime(expire_time_tuple)

  ttl = jsonInfo['data']['ttl']
  
  lastRenewalTime = 0  
  try: 
    lastRenewalTime = jsonInfo['data']['last_renewal_time']
  except KeyError: pass
  
  if (lastRenewalTime > 0):
    percentage = ttl / (expire_time - lastRenewalTime)
  else:
    percentage = ttl / (expire_time - creationTime)
  
  logger.debug('Checked token expiration: percentage -> ' + str(percentage))
  
  if (percentage <= MIN_PERCENTAGE_EXPIRATION and percentage > 0):
    logger.info('Token about to expire... needs renewal')
    jsonInfo = renewal_token()
    lease_duration_vault = jsonInfo['auth']['lease_duration']
    expire_time = int(time.time()) + int(lease_duration_vault)

  elif (percentage <= 0):
    logger.info('Token expired!!')
    return False
  elif force:
    logger.info('Forced renewal')
    jsonInfo = renewal_token()
    lease_duration_vault = jsonInfo['auth']['lease_duration']
    expire_time = int(time.time()) + int(lease_duration_vault)

  #Write expire_time to file
  with open('/marathon-lb/token-status', 'w') as fd:
    fd.write(str(int(expire_time)))

  return True

def renewal_token():
  variables = ''.join(['export VAULT_TOKEN=', vault_token, ';'])
  command = 'token_renewal'
  resp,_ = exec_with_kms_utils(variables, command, '')
  respArr = resp.decode("utf-8").split(',')
  jsonValue = json.loads(','.join(respArr[1:]))
  logger.debug('status ' + respArr[0])
  logger.debug(jsonValue)

  return jsonValue

def exec_with_kms_utils(variables, command, extra_command):
  logger.debug('>>> exec_with_kms_utils: [COMM:'+command+', VARS:'+variables+', EXTRA_COMM:'+extra_command+']')
  proc = subprocess.Popen(['bash', '-c', head_vault_hosts + variables + source_kms_utils + command + ';' + extra_command], shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  
  try:
    resp,_ = proc.communicate(timeout=10)
  except TimeoutExpired:
    proc.kill()
    resp,_ = proc.communicate()

  return resp, proc.returncode

