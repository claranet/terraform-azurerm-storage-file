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
}
