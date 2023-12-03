shell do
  <<~EOS
    rm /etc/localtime
  EOS
end

upload_file message: "Setting Timezone",
  local_file: :timezone,
  remote_path: "/etc/timezone"

shell do
  <<~EOS
    chmod 0644 /etc/timezone
    ln -s /usr/share/zoneinfo/<%= timezone %> /etc/localtime
    chmod 0644 /etc/localtime
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive tzdata
  EOS
end
