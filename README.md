# project-prompts-library

Optional convenience library for archetypes whose name has a
**domain + type** shape — prefix carries the business domain or
subject, suffix qualifies the project's role. Prompts for
`prefix_name` and an optional `suffix_name` and derives `project_name`
with full programming case variants.

## When is this useful?

Reach for project-prompts-library when your archetype generates
projects that fit a naming convention where the first token says
*what the project is about* and the second says *what kind of project
it is*. This is common in service-oriented ecosystems:

```
order-orchestrator            (domain=order, type=orchestrator)
order-service                 (domain=order, type=service)
paypal-adapter                (domain=paypal, type=adapter)
commerce-gateway              (domain=commerce, type=gateway)
inventory-worker              (domain=inventory, type=worker)
auth-sidecar                  (domain=auth, type=sidecar)
```

The prefix names a domain (subject area or integration target); the
suffix names a project type from a small vocabulary that the archetype
can curate via the `suffix_options` answer. Enforcing the convention
at scaffold time prevents the usual drift where some repos are
`order-service` and others are `orders`, `order-svc`, or `ordering`.

### Pair with org-prompts-library for hierarchical names

When the project also sits inside an org/solution hierarchy, compose
with [`org-prompts-library`][org] to derive a full name like
`acme-retail-order-service`:

```
{{ org-solution-name }}-{{ project-name }}
     acme-retail           order-service
```

[org]: https://github.com/archetect-common/org-prompts-library

### When to skip

Not every archetype needs prefix/suffix. Skip when:

- The project name is genuinely free-form (e.g., OSS libraries with
  evocative names: `tokio`, `ripgrep`, `clap`).
- The archetype produces a single, self-named artifact where the
  type is implied by context (e.g., a CLI starter where everything
  is a CLI).
- The naming convention in your org doesn't follow domain-type.
  Some teams prefer feature-based names (`checkout-flow`) or
  module-based (`auth-module`) that don't cleanly split into two
  tokens.

## Contract

| Key | Role |
|---|---|
| `prefix_name` | Required input. The primary name for the project (e.g. `widget`). |
| `suffix_name` | Optional input. Project type qualifier (e.g. `service`, `library`, `cli`). |
| `project_name` | Derived. `"{prefix}-{suffix}"` when suffix is set, otherwise `prefix`. Any pre-set value is overwritten. |

All three keys get full programming case variants via
`Cases.programming()` plus a `_title` variant (e.g. `project_title`,
`prefix_title`, `suffix_title`) via `Cases.fixed(…, Case.Title)`.

The contract is enforced by archetect's prompt machinery. `prefix_name`
is required; `suffix_name` is optional (the prompt is declared with
`optional = true`).

## API

| Call | When to use it |
|---|---|
| `project.prompt(context)` | Prompts for `prefix_name` / `suffix_name` and derives `project_name` |
| `project.run(context)` | Alias for `prompt` — exists only for API symmetry |

There is no `finalize` — the library has no side effects.

## Parent-configurable suffix behavior

Pre-set these context keys before calling `project.prompt` to shape
the suffix prompt:

| Key | Effect |
|---|---|
| `suffix_options` | List of curated suffixes → renders a select prompt instead of free text |
| `suffix_default` | Default value (works with both select and free-text modes) |
| `suffix_allow_other` | When using `suffix_options`, append "Other..." for free-text entry. Default `true` |

## Usage — parent archetype

Free-text suffix:

```yaml
# parent archetype.yaml
catalog:
  project:
    source: "https://github.com/archetect-common/project-prompts-library.git#v1"
    library: true
```

```lua
-- parent archetype.lua
local project = require("project")
project.prompt(context)

-- context now has prefix_name, suffix_name, project_name
-- (plus case variants of each)
```

Curated suffix list:

```yaml
# parent archetype.yaml
catalog:
  project:
    source: "https://github.com/archetect-common/project-prompts-library.git#v1"
    library: true
    answers:
      suffix_options: ["service", "library", "cli"]
      suffix_default: "service"
```

## Usage — standalone

```sh
archetect render https://github.com/archetect-common/project-prompts-library.git#v1
```

## Context keys

### Input

| Key | Example | Notes |
|---|---|---|
| `prefix_name` | `widget` | Required |
| `suffix_name` | `service` | Optional |

### Output

| Field | Example |
|---|---|
| `prefix_name` | `widget` (+ case variants + `prefix_title`) |
| `suffix_name` | `service` (+ case variants + `suffix_title`) |
| `project_name` | `widget-service` (+ case variants + `project_title`) |

## Testing locally

While iterating on this library or a parent archetype that consumes
it, render against the local working copy with `--local`:

```sh
archetect render --local \
    /Users/jimmie/personal/archetect-common/project-prompts-library
```

When a parent archetype is under development, `--local` also causes
its library dependencies to resolve to the local checkouts configured
via `archetect config` — including this one — so changes here take
effect immediately without cutting a new tag.

## Release versioning

This library comes wired with the
[`archetect-actions/repository-release`](https://github.com/archetect-actions/repository-release)
action. Trigger a `minor_release` via the GitHub Actions tab to cut
`v1.0` and an auto-updating `v1` floating tag.
