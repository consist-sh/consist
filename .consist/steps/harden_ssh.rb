name "Harden the SSH config"

mutate_file mode: :replace, target_file: "/etc/ssh/sshd_config", match: "^#PasswordAuthentication yes$",
  target_string: "PasswordAuthentication no"
mutate_file mode: :replace, target_file: "/etc/ssh/sshd_config", match: "^#PubkeyAuthentication yes$",
  target_string: "PubkeyAuthentication yes"

shell do
  <<~EOS
    service ssh restart
  EOS
end
