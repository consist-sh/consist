name "Update the APT packages"
required_user :root

shell do
  <<~EOS
    apt-get update && apt-get upgrade -y
  EOS
end
