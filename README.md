# consist

[![Gem Version](https://img.shields.io/gem/v/consist)](https://rubygems.org/gems/consist)
[![Gem Downloads](https://img.shields.io/gem/dt/consist)](https://www.ruby-toolbox.com/projects/consist)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/consist-sh/consist/ci.yml)](https://github.com/consist-sh/consist/actions/workflows/ci.yml)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/consist-sh/consist)](https://codeclimate.com/github/consist-sh/consist)

**THIS IS BETA SOFTWARE UNDER ACTIVE DEVELOPMENT. APIs AND FEATURES WILL CHANGE.**

> consist - (noun): a set of railroad vehicles forming a complete train.

`consist` is the one person framework server scaffolder. It is stone age tech.

You can use it to quickly baseline a raw server using a given recipe provided
by Consist. I use it to baseline new Droplets to be ready to run Kamal in
single server setup for a Rails monolith. While Kamal will setup Docker
for you, it does not do anything else related to configuring the underlying
server, such as firewalls, general hardening, enabling swapfile etc.

## Project Principles

- Minimal tool specific language / knowledge required to use Consist
- Procedural declaration execution - no converging, orchestration or
  event driven operation
- If you can shell script it, you can consist it directly

---

- [Quick start](#quick-start)
- [Support](#support)
- [Rationale](#rationale)
- [Key Concepts](#key-concepts)
- [Is It Good?](#is-it-good%3F)
- [License](#license)
- [Code of conduct](#code-of-conduct)
- [Contribution guide](#contribution-guide)

## Quick start

```sh
gem install consist
```

You must be already auth'd with the server you want to scaffold. `consist` will use
your SSH id to perform actions.

Then, you have two ways of interacting with Consist. First is the `scaffold` command:

```sh
consist scaffold <recipe_name> root <ip_address>
```

Will kick off the scaffolding of that given server with the given
recipe, using the `root` user.

The other way of using `consist` is to go with a `Consistfile` in
your project root that describes the recipe and steps. Then you can say:

```sh
consist up <ip_address>
```

And `consist` will do it's thing with that given IP address.

## Features

- Simple Ruby based DSL
- ERB interpolation of config on shell commands and file contents
- Small API surface area - quick to learn

## Rationale

I wanted a super-simple tool, that was baked in Ruby, for setting up
random servers to specific configurations. This is the result.

On a scale of 1 to 10, with 10 being Terraform, this tool is basically
as low-rent you can get to hand running scripts yourself, so about a 3
on the scale.

If you know how to shell script what you want, you can stick it in a step,
and add it to a recipe.

The more I work in this industry, the less I see using other people's code
and tools as a benefit, and more of a liability. I appreciate the paradox I'm
creating here for you 😅

### Why not use Terraform / Ansible / Salt etc?

I think they are bad tools for my needs. I wanted something simple
I could hack on, grow only when needed, and will work specifically
without ambiguity. For example, Ansible has a lot of nonsense with case sensitivity,
Terraform does [weird unexpected things](https://github.com/hashicorp/terraform/issues/16330).

I didn't want to keep maintaining specific knowledge of these infrastructure
as code tools in my brain anymore, along with all of their peculiarities and oddities.

**If you prefer those tools, go ahead and use them.**

Ain't nobody stopping you.

## Key Concepts

Consist leans on three primary ideas: recipes, steps and files. Recipes contain
one or more steps. Steps tend to be atomic and idempotent.

### Recipes

Example of a recipe:

```ruby
name "Kamal Single Server"
description "Sets up a single server to run Kamal"
user :root

steps do
  step :update_apt_packages
  step :install_apt_packages
end
```

### Steps

Example of a step:

```ruby
name "Install APT packages"
required_user :root

shell "Installing essential packages" do
  <<~EOS
    apt-get -y remove systemd-timesyncd
    timedatectl set-ntp no
    apt-get -y install build-essential curl fail2ban git ntp vim
    apt-get autoremove
    apt-get autoclean
  EOS
end

shell "Start NTP and Fail2Ban" do
  <<~EOS
    service ntp restart
    service fail2ban restart
  EOS
end
```

### Files

Example of a file:

```ruby
file :hostname do
  <<~EOS
  <%= hostname %>
  EOS
end
```

### Consistfile

A `Consistfile` is a portable giant file of a recipe and all its
steps. Something like (this is a _full_ example, in practice you
would reference some of Consist's built in steps):

```ruby
consist do
  config :hostname, "testexample.com"
  config :site_fqdn, "textexample.com"
  config :admin_email, "j@jmd.fm"
  config :swap_size, "2G"
  config :swap_swappiness, "60"
  config :timezone, "UTC"

  file :apt_auto_upgrade do
    <<~EOS
      APT::Periodic::AutocleanInterval "7";
      APT::Periodic::Update-Package-Lists "1";
      APT::Periodic::Unattended-Upgrade "1";
    EOS
  end

  file :hostname do
    <<~EOS
      <%= hostname %>
    EOS
  end

  file :timezone do
    <<~EOS
      <%= timezone %>
    EOS
  end

  file :fail2ban_config do
    <<~EOS
      # Fail2Ban configuration file.
      #

      # to view current bans, run one of the following:
      # fail2ban-client status ssh
      # iptables --list -n | fgrep DROP

      # The DEFAULT allows a global definition of the options. They can be overridden
      # in each jail afterwards.

      [DEFAULT]

      ignoreip = 127.0.0.1
      bantime  = 600
      maxretry = 3
      backend = auto
      usedns = warn
      destemail = <%= admin_email %>

      #
      # ACTIONS
      #

      banaction = iptables-multiport
      mta = sendmail
      protocol = tcp
      chain = INPUT

      #
      # Action shortcuts. To be used to define action parameter

      # The simplest action to take: ban only
      action_ = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]

      # ban & send an e-mail with whois report to the destemail.
      action_mw = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
                    %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s"]

      # ban & send an e-mail with whois report and relevant log lines
      # to the destemail.
      action_mwl = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
                     %(mta)s-whois-lines[name=%(__name__)s, dest="%(destemail)s", logpath=%(logpath)s, chain="%(chain)s"]

      # default action
      action = %(action_mw)s

      [ssh]

      enabled  = true
      port = 987
      filter   = sshd
      logpath  = /var/log/auth.log
      maxretry = 6

      [ssh-ddos]

      enabled = true
      port = 987
      filter   = sshd-ddos
      logpath  = /var/log/auth.log
      maxretry = 6
    EOS
  end

  file :logwatch_config do
    <<~EOS
      Output = mail
      MailTo = <%= admin_email %>
      MailFrom = logwatch@host1.mydomain.org
      Detail = Low
      Service = All
    EOS
  end

  file :sysctl_config do
    <<~EOS
      # Do not accept ICMP redirects (prevent MITM attacks)
      net.ipv4.conf.all.accept_redirects = 0
      net.ipv6.conf.all.accept_redirects = 0
      # Do not send ICMP redirects (we are not a router)
      net.ipv4.conf.all.send_redirects = 0
      # Log Martian Packets
      net.ipv4.conf.all.log_martians = 1
      # Controls IP packet forwarding
      net.ipv4.ip_forward = 0
      # Controls source route verification
      net.ipv4.conf.default.rp_filter = 1
      # Do not accept source routing
      net.ipv4.conf.default.accept_source_route = 0
      # Controls the System Request debugging functionality of the kernel
      kernel.sysrq = 0
      # Controls whether core dumps will append the PID to the core filename
      # Useful for debugging multi-threaded applications
      kernel.core_uses_pid = 1
       # Controls the use of TCP syncookies
      net.ipv4.tcp_synack_retries = 2
      ######## IPv4 networking start ###########
      # Send redirects, if router, but this is just server
      net.ipv4.conf.all.send_redirects = 0
      net.ipv4.conf.default.send_redirects = 0
      # Accept packets with SRR option? No
      net.ipv4.conf.all.accept_source_route = 0
      # Accept Redirects? No, this is not router
      net.ipv4.conf.all.accept_redirects = 0
      net.ipv4.conf.all.secure_redirects = 0
      # Log packets with impossible addresses to kernel log? Yes
      net.ipv4.conf.all.log_martians = 1
      net.ipv4.conf.default.accept_source_route = 0
      net.ipv4.conf.default.accept_redirects = 0
      net.ipv4.conf.default.secure_redirects = 0
      # Ignore all ICMP ECHO and TIMESTAMP requests sent to it via broadcast/multicast
      net.ipv4.icmp_echo_ignore_broadcasts = 1
      # Prevent against the common 'syn flood attack'
      net.ipv4.tcp_syncookies = 1
      # Enable source validation by reversed path, as specified in RFC1812
      net.ipv4.conf.all.rp_filter = 1
      net.ipv4.conf.default.rp_filter = 1
      ######## IPv6 networking start ###########
      # Number of Router Solicitations to send until assuming no routers are present.
      # This is host and not router
      net.ipv6.conf.default.router_solicitations = 0
      # Accept Router Preference in RA?
      net.ipv6.conf.default.accept_ra_rtr_pref = 0
      # Learn Prefix Information in Router Advertisement
      net.ipv6.conf.default.accept_ra_pinfo = 0
      # Setting controls whether the system will accept Hop Limit settings from a router advertisement
      net.ipv6.conf.default.accept_ra_defrtr = 0
      #router advertisements can cause the system to assign a global unicast address to an interface
      net.ipv6.conf.default.autoconf = 0
      #how many neighbor solicitations to send out per address?
      net.ipv6.conf.default.dad_transmits = 0
      # How many global unicast IPv6 addresses can be assigned to each interface?
      net.ipv6.conf.default.max_addresses = 1
      ######## IPv6 networking ends ###########
      # Disabled, not used anymore
      #Enable ExecShield protection |
      #kernel.exec-shield = 1
      #kernel.randomize_va_space = 1
      # TCP and memory optimization
      # increase TCP max buffer size setable using setsockopt()
      #net.ipv4.tcp_rmem = 4096 87380 8388608
      #net.ipv4.tcp_wmem = 4096 87380 8388608
      # increase Linux auto tuning TCP buffer limits
      #net.core.rmem_max = 8388608
      #net.core.wmem_max = 8388608
      #net.core.netdev_max_backlog = 5000
      #net.ipv4.tcp_window_scaling = 1
      # increase system file descriptor limit
      fs.file-max = 65535
      #Allow for more PIDs
      kernel.pid_max = 65536
      #Increase system IP port limits
      net.ipv4.ip_local_port_range = 2000 65000
      # Disable IPv6 autoconf
      #net.ipv6.conf.all.autoconf = 0
      #net.ipv6.conf.default.autoconf = 0
      #net.ipv6.conf.eth0.autoconf = 0
      #net.ipv6.conf.all.accept_ra = 0
      #net.ipv6.conf.default.accept_ra = 0
      #net.ipv6.conf.eth0.accept_ra = 0
    EOS
  end

  recipe :kamal_single_server do
    name "Kamal Single Server Scaffold"

    steps do
      step :set_hostname do
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
      end

      step :setup_timezone do
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
      end

      step :update_apt_packages do
        name "Updating APT packages"
        required_user :root

        upload_file message: "Uploading APT config...",
          local_file: :apt_auto_upgrade,
          remote_path: "/etc/apt/apt.conf.d/20auto-upgrades"

        shell do
          <<~EOS
            apt-get update && apt-get upgrade -y
            apt-get autoremove
            apt-get autoclean
          EOS
        end
      end

      step :install_apt_packages do
        name "Installing essential APT packages"
        required_user :root

        shell "Installing essential packages" do
          <<~EOS
            apt-get -y install build-essential curl git vim
          EOS
        end
      end

      step :setup_ntp do
        name "Installing NTP daemon"
        required_user :root

        shell "Configuring NTP daemon", params: {raise_on_non_zero_exit: false} do
          <<~EOS
            apt-get -y remove systemd-timesyncd
            timedatectl set-ntp no 2>1
            apt-get -y install ntp
          EOS
        end

        shell "Start NTP and Fail2Ban" do
          <<~EOS
            service ntp restart
          EOS
        end
      end

      step :install_fail2ban do
        name "Installing fail2ban"
        required_user :root

        shell "Installing essential packages" do
          <<~EOS
            apt-get -y install fail2ban
          EOS
        end

        upload_file message: "Uploading fail2ban confing", local_file: :fail2ban_config,
          remote_path: "/etc/fail2ban/jail.local"

        shell "Start Fail2Ban" do
          <<~EOS
            service fail2ban restart
            systemctl enable fail2ban.service
          EOS
        end
      end

      step :setup_swap do
        name "Configure and enable the swapfile"
        required_user :root

        check status: :nonexistant, file: "/swapfile" do
          shell do
            <<~EOS
              fallocate -l <%= swap_size %> /swapfile
              chmod 600 /swapfile
              mkswap /swapfile
              swapon /swapfile
              echo "\n/swapfile swap swap defaults 0 0\n" >> /etc/fstab
              sysctl vm.swappiness=<%=swap_swappiness%>
              echo "\nvm.swappiness=<%=swap_swappiness%>\n" >> /etc/sysctl.conf
            EOS
          end
        end
      end

      step :harden_ssh do
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
      end

      step :harden_system do
        name "Harden the SYSCTL settings"

        upload_file message: "Uploading sysctl config...",
          local_file: :sysctl_config,
          remote_path: "/tmp/sysctl_config"

        shell do
          <<~EOS
            cat /etc/sysctl.conf /tmp/sysctl_config > /etc/sysctl.conf
            rm /tmp/sysctl_config
            sysctl -p
          EOS
        end
      end

      step :setup_ufw do
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
      end

      step :setup_postfix do
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
      end

      step :setup_logwatch do
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
      end

      step :setup_docker do
        name "Setup Docker"

        shell do
          <<~EOS
            # Add Docker's official GPG key:
            apt-get update
            apt-get install ca-certificates curl gnupg -y
            install -m 0755 -d /etc/apt/keyrings
            rm /etc/apt/keyrings/docker.gpg
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --batch --no-tty --dearmor -o /etc/apt/keyrings/docker.gpg
            chmod a+r /etc/apt/keyrings/docker.gpg

            # Add the repository to Apt sources:
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update

            # Install Docker
            apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

            # Make Docker start on boot
            sudo systemctl enable docker.service
            sudo systemctl enable containerd.service
          EOS
        end

        shell "Create docker group", params: {raise_on_non_zero_exit: false} do
          <<~EOS
            # Create group
            sudo groupadd docker
            sudo usermod -aG docker $USER
          EOS
        end

        shell "Create default private network", params: {raise_on_non_zero_exit: false} do
          <<~EOS
            # Create default private network
            docker network create private
          EOS
        end
      end
    end
  end
end

# vim: filetype=ruby
```

Given a `Consistfile` you could then say `consist up <ip_address>` and
it would just work.

## Is it good?

I think so. But I don't know, use your own brain or something. Don't listen to
me.

## Support

If you want to report a bug, or have ideas, feedback or questions about the gem,
[let me know via GitHub issues](https://github.com/johnmcdowall/consist/issues/new)
and I will do my best to provide a helpful answer.

## License

The gem is available as open source under the terms of the [LGPLv3 License](LICENSE.txt).

## Code of conduct

Everyone interacting in this project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Contribution guide

Pull requests are welcome, but I want you to open an Issue first to discuss your
ideas. Thanks.

## Development

1. Clone the repo
2. Run `bundle install`
3. Run `bin/dev` to execute consist locally without having to build and install.
