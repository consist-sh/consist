---
layout: docs
title: Overview
description: Learn more about Consist
section: Introduction
category: ""
---

**THIS IS BETA SOFTWARE UNDER ACTIVE DEVELOPMENT. APIs AND FEATURES WILL CHANGE.**

> consist - (noun): a set of railroad vehicles forming a complete train.

`consist` is the stone age one person framework server scaffolder.

You can use it to quickly baseline a raw server using a given recipe written in
a DSL that is provided by `consist`. You can use it to baseline new Droplets
to be ready to run Kamal in single server setup for a Rails monolith.

While Kamal will setup Docker for you, it does not do anything else related
to configuring the underlying server, such as firewalls, general hardening,
enabling swapfile etc.

That said, there is nothing Rails or Kamal specific about `consist` - they just
work great together like flint and flammable materials.

## Project Principles

- Minimal tool specific language / knowledge required to use Consist
- Procedural declaration execution - no converging, orchestration or
  event driven operation
- If you can shell script it, you can `consist` it directly
