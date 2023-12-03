name "Installing essential APT packages"
required_user :root

shell "Installing essential packages" do
  <<~EOS
    apt-get -y install build-essential curl git vim
  EOS
end
