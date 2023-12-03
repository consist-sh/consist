name "Harden the SYSCTL settings"

upload_file message: "Uploading sysctl config...",
  local_file: :sysctl_config,
  remote_path: "/tmp/sysctl_config"

shell do
  <<~EOS
    cat /etc/sysctl.conf /tmp/sysctl_config > /etc/sysctl.conf
    rm /tmp/sysctl_config
    sysctl -p
  EOS
end
