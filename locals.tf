locals {
  backup_vault_name = split("/", var.backup_policy_id)[8]
  backup_vault_rg   = split("/", var.backup_policy_id)[4]

  cifs_creds_file_path    = format("/etc/smbcredentials/%s.cred", module.storage_account.storage_account_name)
  cifs_creds_file_content = <<-EOF
    username=${module.storage_account.storage_account_name}
    password=${module.storage_account.storage_account_properties.primary_access_key}
EOF
  mount_options = {
    for s in var.file_shares : s.name => s.enabled_protocol == "NFS" ?
    "rw,noatime,vers=4.1,rsize=1048576,wsize=1048576,namlen=255,acregmin=600,acregmax=600,acdirmin=600,acdirmax=600" :
    "nofail,credentials=${local.cifs_creds_file_path},dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30"
  }

  mount_cmds = {
    for s in var.file_shares : s.name => s.enabled_protocol == "NFS" ?
    <<CMD
sudo mkdir -p "/mnt/${module.storage_account.storage_account_name}/${s.name}"
sudo mount -t nfs "${module.storage_account.storage_account_properties.primary_file_host}/${module.storage_account.storage_account_name}/${s.name}" "/mnt/${module.storage_account.storage_account_name}/${s.name}" -o ${local.mount_options[s.name]}
CMD
    :
    <<CMD
sudo mkdir -p "/mnt/${s.name}"
sudo mount -t cifs "//${module.storage_account.storage_account_properties.primary_file_host}/${s.name}" "/mnt/${s.name}" -o ${local.mount_options[s.name]}
CMD
  }

  smb_properties = var.is_premium ? merge(
    { multichannel_enabled = true },
    var.file_share_properties_smb == null ? {} : tomap(var.file_share_properties_smb)
  ) : var.file_share_properties_smb == null ? null : tomap(var.file_share_properties_smb)
}
