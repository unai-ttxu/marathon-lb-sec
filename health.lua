function check_token()

  local vault_host = "VAULT_HOSTS=" .. os.capture("env | grep STRING_VAULT_HOST | cut -d '=' -f 2 | cut -d ',' -f 1")
  local is_ok = os.execute("bash -c \"source /usr/sbin/kms_utils.sh && " .. vault_host .. " token_info > /dev/null 2>&1 \"")

  if is_ok==true then
        return 200
  else
        return 501
  end
end

core.register_service("health", "http", function(applet)
   token_status = check_token()
   if token_status == 200 then
     response = "OK"
   else
     response = "Something went wrong"
   end
   applet:set_status(token_status)
   applet:add_header("content-length", string.len(response))
   applet:add_header("content-type", "text/plain")
   applet:start_response()
   applet:send(response)
end)
