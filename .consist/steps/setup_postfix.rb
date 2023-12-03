name "Install Postfix for admin emails"

shell do
  <<~EOS
    echo "postfix postfix/mailname string <%= site_fqdn %>" | debconf-set-selections
  EOS
end

shell do
  <<~EOS
    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
  EOS
end

shell do
  <<~EOS
    DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes postfix
  EOS
end
