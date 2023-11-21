name "Install APT packages"
required_user :root

shell "Installing essential packages" do
  <<~EOS
    apt-get -y remove systemd-timesyncd
    timedatectl set-ntp no
    apt-get -y install build-essential curl fail2ban git ntp vim
    apt-get autoremove
    apt-get autoclean
  EOS
end

shell "Start NTP and Fail2Ban" do
  <<~EOS
    service ntp restart
    service fail2ban restart
  EOS
end
