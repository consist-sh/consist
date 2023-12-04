---
layout: docs
title: Quick Start
description: Get right to work
section: Introduction
category: ""
---

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

## Initialization

To create a blank `Consistfile` in your project, execute:

```bash
consist init
```

If you want to use a community created `Consistfile` all you have to do is
specify the Github repo path as part of the `init`. For example, to use the
community Kamal Single Server Setup Consistfile:

```bash
consist init consist-sh/kamal-single-server
```

And the `Consistfile` at `consist-sh/kamal-single-server` and its associated
artifacts will be cloned down into your project root. You can then run:

```bash
consist up <ip_address>
```

And the `Consistfile` will be executed against your server at the given IP.
