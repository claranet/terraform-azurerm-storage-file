locals {
  backup_vault_name = try(split("/", var.backup_policy_id)[8], null)
  backup_vault_rg   = try(split("/", var.backup_policy_id)[4], null)

  smb_properties = {
    versions                        = try(var.file_share_properties_smb.versions, null)
    authentication_types            = try(var.file_share_properties_smb.authentication_types, null)
    kerberos_ticket_encryption_type = try(var.file_share_properties_smb.kerberos_ticket_encryption_type, null)
    channel_encryption_type         = try(var.file_share_properties_smb.channel_encryption_type, null)
    multichannel_enabled            = try(var.file_share_properties_smb.multichannel_enabled, var.is_premium)
  }


  cifs_creds_file_path    = format("/etc/smbcredentials/%s.cred", module.storage_account.storage_account_name)
  cifs_creds_file_content = <<-EOF
    username=${module.storage_account.storage_account_name}
    password=${module.storage_account.storage_account_properties.primary_access_key}
EOF
  mount_options = {
    for s in var.file_shares : s.name => s.enabled_protocol == "NFS" ?
    "rw,noatime,_netdev,vers=4.1,rsize=1048576,wsize=1048576,namlen=255,acregmin=600,acregmax=600,acdirmin=600,acdirmax=600,nconnect=4" :
    "nofail,_netdev,credentials=${local.cifs_creds_file_path},dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30"
  }

  mount_endpoints = { for s in var.file_shares :
    s.name => s.enabled_protocol == "NFS" ?
    format("%s:/%s/%s", module.storage_account.storage_account_properties.primary_file_host, module.storage_account.storage_account_name, s.name) :
    format("//%s/%s", module.storage_account.storage_account_properties.primary_file_host, s.name)
  }

  mount_paths = { for s in var.file_shares : s.name => "/mnt/${module.storage_account.storage_account_name}/${s.name}" }

  mount_cmds = {
    for s in var.file_shares : s.name => s.enabled_protocol == "NFS" ?
    <<CMD
sudo mkdir -p "${local.mount_paths[s.name]}"
sudo mount -t nfs "${local.mount_endpoints[s.name]}" "${local.mount_paths[s.name]}" -o ${local.mount_options[s.name]}
CMD
    :
    <<CMD
sudo mkdir -p "${local.mount_paths[s.name]}"
sudo mount -t cifs "${local.mount_endpoints[s.name]}" "${local.mount_paths[s.name]}" -o ${local.mount_options[s.name]}
CMD
  }

  fstab_entries = {
    for s in var.file_shares : s.name => s.enabled_protocol == "NFS" ?
    "${local.mount_endpoints[s.name]} ${local.mount_paths[s.name]} nfs ${local.mount_options[s.name]}" :
    "${local.mount_endpoints[s.name]} ${local.mount_paths[s.name]} cifs ${local.mount_options[s.name]}"
  }
}
