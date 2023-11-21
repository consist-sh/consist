# consist

[![Gem Version](https://img.shields.io/gem/v/consist)](https://rubygems.org/gems/consist)
[![Gem Downloads](https://img.shields.io/gem/dt/consist)](https://www.ruby-toolbox.com/projects/consist)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/johnmcdowall/consist/ci.yml)](https://github.com/johnmcdowall/consist/actions/workflows/ci.yml)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/johnmcdowall/consist)](https://codeclimate.com/github/johnmcdowall/consist)

`consist` is the one person framework server scaffolder. You can use it to quickly
baseline a raw server using a given recipe provided by Consist. I use it to
baseline new Droplets to be ready to run Kamal in single server setup for
a Rails monolith.

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

Then:

```sh
consist scaffold <recipe_name> root <ip_address>
```

Will kick off the scaffolding of that given server with the given recipe.

## Rationale

I wanted a super-simple tool, that was baked in Ruby, for setting up
random servers to specific configurations. This is the result.

On a scale of 1 to 10, with 10 being Terraform, this tool is basically
as low-rent you can get to hand running scripts yourself, so about a 3
on the scale.

If you know how to shell script what you want, you can stick it in a step,
and add it to a recipe.

### Why not use Terraform / Ansible / Salt etc?

Because I think they are bad tools that are overblown for my needs. I wanted something
I could hack on, and will work specifically without ambiguity. For example, Ansible
has a lot of nonsense with case sensitivity, Terraform does [weird unexpected things](https://github.com/hashicorp/terraform/issues/16330).

I also didn't want to maintain specific knowledge of these infrastructure
as code tools in my brain anymore, and all of their peculiarities and oddities.

If you like those tools, go ahead and use them. Ain't nobody stopping you.

## Key Concepts

Consist leans on two primary ideas: recipes and steps. Recipes contain one or more
steps. Steps tend to be atomic and idempotent.

## Is it good?

I think so. But I don't know, use your own brain or something. Don't listen to
me.

## Support

If you want to report a bug, or have ideas, feedback or questions about the gem,
[let me know via GitHub issues](https://github.com/johnmcdowall/consist/issues/new)
and I will do my best to provide a helpful answer.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Code of conduct

Everyone interacting in this project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Contribution guide

Pull requests are welcome, but I want you to open an Issue first to discuss your
ideas. Thanks.
