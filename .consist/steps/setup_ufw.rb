name "Setup UFW"

shell do
  <<~EOS
    ufw logging on
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22
    ufw allow 80
    ufw allow 443
    ufw --force enable
    service ufw restart
  EOS
end
