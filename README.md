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
- If you can shell script it, you can `consist` it directly
- Encouraging sharing of portable `Consistfiles` across the community

---

- [Quick start](#quick-start)
- [Support](#support)
- [Rationale](#rationale)
- [Key Concepts](#key-concepts)
  - [Recipes](#recipes)
  - [Steps](#steps)
  - [Files](#files)
  - [Consistfile](#consistfile)
  - [Artifacts](#artifacts)
  - [.consist directory](#.consist-directory)
- [Community Consistfiles](#community-consistfiles)
- [Is It Good?](#is-it-good%3F)
- [License](#license)
- [Code of conduct](#code-of-conduct)
- [Contribution guide](#contribution-guide)

## Quick start

Make sure the `consist` gem is installed:

```sh
gem install consist
```

You must be already authenticated with the server you want to scaffold.
`consist` will use your account's SSH id to perform actions.

The main way of using `consist` is to go with a `Consistfile` in
your project root that describes the recipe and steps. Then you can say:

```sh
consist up <ip_address> [--consistfile=/path/to/consistfile] [--consistdir=/path/to/.consistdir]
```

And `consist` will do it's thing with that given IP address.

To create a blank `Consistfile` in your project, execute:

```ruby
consist init
```

## Commands

Other commands available:

- `consist init [account/repo]` - initialize your project with a new Consist file. Optionally,
  you can specify a Github `account/repo` path and that location will be used to clone down a
  Consistfile, and any associated artifacts needed by the Consistfile.
- `consist ping <ip_address>` - checks you can connect and authenticate with the given IP

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
would reference some of Consists' built in steps):

```ruby
# This is a shortened non-complete example.
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
    end
  end
end

# vim: filetype=ruby
```

Given a `Consistfile` you could then say `consist up <ip_address>` and
it would just work.

### Artifacts

Artifacts allow you to split out your `Consistfile` into separate files.

You can create blocks in the `Consistfile` as shown above, but you can also only
specify an `id`, and that `id` will be used to try and attempt to load a file of that
name in the `.consist/<type>/<id>` directory. For example, referencing a file:

```ruby
file :apt_auto_upgrade
```

Will attempt to load a file in `.consist/files/apt_auto_upgrade`. The same is
possible for any of the main types: `files`, `steps`, and `recipes`

### `.consist` directory

The `.consist` directory is assumed to be in the root of your project, and should
contain three subdirectories for each of the types: `files`, `steps`, `recipes`.

You can specify an alternate directory location by passing the `--consistdir` switch
to the `up` command.

## Community Consistfiles

If you create a Github repo, and all it contains is a `Consistfile` and any associated
artifacts under a `.consist` directory, other people will be able to use it by
executing `consist init <gh_repo_path>` in their project root.

If you create one, please open a PR to include it here:

| Name                      | Repo                                                                                | Description                                                 |
| ------------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| Kamal Single Server Setup | [consist-sh/kamal-single-server](https://github.com/consist-sh/kamal-single-server) | Setup a single server with good defaults ready to run Kamal |

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

Make sure any PRs have been formatted with `standard`.
