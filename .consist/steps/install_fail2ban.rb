name "Installing fail2ban"
required_user :root

shell "Installing essential packages" do
  <<~EOS
    apt-get -y install fail2ban
  EOS
end

upload_file message: "Uploading fail2ban confing", local_file: :fail2ban_config,
  remote_path: "/etc/fail2ban/jail.local"

shell "Start Fail2Ban" do
  <<~EOS
    service fail2ban restart
    systemctl enable fail2ban.service
  EOS
end
