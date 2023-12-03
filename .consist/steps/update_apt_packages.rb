name "Updating APT packages"
required_user :root

upload_file message: "Uploading APT config...",
  local_file: :apt_auto_upgrade,
  remote_path: "/etc/apt/apt.conf.d/20auto-upgrades"

shell do
  <<~EOS
    apt-get update && apt-get upgrade -y
    apt-get autoremove
    apt-get autoclean
  EOS
end
