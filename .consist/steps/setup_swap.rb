name "Configure and enable the swapfile"
required_user :root

check status: :nonexistant, file: "/swapfile" do
  shell "Configuring Swapfile" do
    <<~EOS
      fallocate -l <%= swap_size %> /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo "\\n/swapfile swap swap defaults 0 0\\n" >> /etc/fstab
      sysctl vm.swappiness=<%=swap_swappiness%>
      echo "\\nvm.swappiness=<%=swap_swappiness%>\\n" >> /etc/sysctl.conf
    EOS
  end
end
