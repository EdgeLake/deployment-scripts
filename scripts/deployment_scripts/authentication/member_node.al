#--------------------------------------------------------------------------------------------------------
# Create member policy for a node. Each node should have its own member policy.
#--------------------------------------------------------------------------------------------------------
# process !local_scripts/deployment_scripts/authentication/member_node.al

:declare-params:
on error ignore
set node_password = passwd
if $NODE_PASSWORD then node_password = $NODE_PASSWORD
key_name = python !node_name.replace("-", "_").replace(" ", "_").strip()

is_policy = blockchain get member where type=node and name=!node_name and company=!company_name
if !is_policy then goto end-script

:clean-keys:
del_name = !id_dir + !key_name + "*"
system rm -rf !del_name

:create-keys:
on error goto create-keys-error
id create keys where password = !node_password and keys_file = !key_name

on error ignore
private_key = get private key where keys_file = !key_name
if not !private_key then goto private-key-error

:prepare-policy:
<new_policy = {"member": {
    "type" : "node",
    "name": !node_name,
    "company": !company_name
}}>

:prepare-policy:
on error goto prepare-policy-error
new_policy = id sign !new_policy where key = !private_key and password = !node_password
validate_policy = json !new_policy
if not !validate_policy then goto prepare-policy-error

:declare-policy:
on error call declare-policy-error
blockchain prepare policy !new_policy
blockchain insert where policy=!new_policy and local=true and master=!ledger_conn

:end-script:
end script

:create-keys-error:
echo "Failed to create root keys. Cannot continue with process"
goto end-script

:private-key-error:
echo "Failed to get private key rom generated root key"
goto end-script

:public-key-error:
echo "Missing public key, cannot create valid member policy"
goto end-script

:prepare-policy-error:
echo "Failed to prepare member root policy for publishing on blockchain"
goto end-script

:declare-policy-error:
echo "Error: Failed to declare policy for root member"
return
