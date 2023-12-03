name "Installing NTP daemon"
required_user :root

shell "Configuring NTP daemon", params: {raise_on_non_zero_exit: false} do
  <<~EOS
    apt-get -y remove systemd-timesyncd
    timedatectl set-ntp no 2>1
    apt-get -y install ntp
  EOS
end

shell "Start NTP and Fail2Ban" do
  <<~EOS
    service ntp restart
  EOS
end
