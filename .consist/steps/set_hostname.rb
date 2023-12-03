upload_file message: "Setting hostname",
  local_file: :hostname,
  remote_path: "/etc/hostname"

shell do
  <<~EOS
    hostname <%= Consist.config[:hostname] %>
  EOS
end

mutate_file mode: :replace, target_file: "/etc/hosts", match: "^127.0.0.1 localhost$",
  target_string: "127.0.0.1 localhost <%= hostname %>"
