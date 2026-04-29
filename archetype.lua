-- project-prompts-library standalone / one-shot entry point.
--
-- Parents wanting to consume this library should depend on it with
-- `library: true` and call `require("project").prompt(context)` — see
-- the README. This script runs when the archetype is invoked directly
-- (`archetect render project-prompts-library`) or via plain
-- `catalog.render("project", ctx)` without `library: true`.

local context = Context.new()
require("lib").run(context)
return context
