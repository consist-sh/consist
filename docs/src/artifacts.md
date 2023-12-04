---
layout: docs
title: Artifacts
description: Split up your Consistfile with Artifacts
section: Consistfile
category: ""
---

# Artifacts

Artifacts allow you to split out your `Consistfile` into separate files.

You can create blocks in the `Consistfile` as shown above, but you can also only
specify an `id`, and that `id` will be used to try and attempt to load a file of that
name in the `.consist/<type>/<id>` directory. For example, referencing a file:

```ruby
file :apt_auto_upgrade
```

Will attempt to load a file in `.consist/files/apt_auto_upgrade`. The same is
possible for any of the main types: `files`, `steps`, and `recipes`
