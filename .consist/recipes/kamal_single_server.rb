name "Kamal Single Server Scaffold"

steps do
  step :set_hostname
  step :setup_timezone
  step :update_apt_packages
  step :install_apt_packages
  step :setup_ntp
  step :install_fail2ban
  step :setup_swap
  step :harden_ssh
  step :harden_system
  step :setup_ufw
  step :setup_postfix
  step :setup_logwatch
  step :setup_docker
end
