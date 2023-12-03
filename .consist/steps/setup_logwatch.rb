name "Setup Logwatch to automate log reporting"

shell do
  <<~EOS
    DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes logwatch
  EOS
end

mutate_file mode: :replace, target_file: "/etc/cron.daily/00logwatch", match: "^/usr/sbin/logwatch --output mail$",
  target_string: "/usr/sbin/logwatch --output mail --mailto <%= admin_email %> --detail high", delim: "#"

upload_file message: "Uploading Logwatch confing", local_file: :logwatch_config,
  remote_path: "/etc/logwatch/conf"
