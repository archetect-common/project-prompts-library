-- project-prompts-library main module.
--
-- Consumers that mount this archetype with `library: true` under the
-- catalog key `project` (or any name they choose) reach this module
-- via `require("project")`. The archetype's own shim reaches it via
-- `require("lib")`.
--
-- Contract
-- ────────
-- Treats `prefix_name` as the authoritative primary input and
-- `suffix_name` as an optional qualifier. Derives `project_name` from
-- the two. When no suffix is provided, `project_name` equals
-- `prefix_name`. Any pre-set `project_name` is overwritten.
--
-- Parent-configurable behavior
-- ────────────────────────────
-- Parent archetypes can pre-set context keys to shape the suffix
-- prompt before `prompt` is called:
--
--   suffix_options      — list of curated suffixes; absent → free text prompt
--   suffix_default      — default value (in or out of the list)
--   suffix_allow_other  — when options are used, append "Other..." for free
--                         text (default: true — escape hatches are friendly)
--
-- When used optional
-- ──────────────────
-- Not every archetype has a prefix + suffix shape. Plenty of projects
-- have a single free-form name, or use org-prompts-library's
-- org+solution composition instead. Reach for this library only when
-- your archetype genuinely has the prefix/suffix structure.

local M = {}

function M.prompt(context)
    context:prompt_text("Project Prefix:", "prefix_name", {
        cases = { Cases.programming(), Cases.fixed("prefix_title", Case.Title) },
        placeholder = "widget",
        help = "The primary name for the project.",
    })

    local suffix_options     = context:get("suffix_options")
    local suffix_default     = context:get("suffix_default")
    local suffix_allow_other = context:get("suffix_allow_other")
    if suffix_allow_other == nil then suffix_allow_other = true end

    if suffix_options then
        context:prompt_select("Project Suffix:", "suffix_name", suffix_options, {
            cases = { Cases.programming(), Cases.fixed("suffix_title", Case.Title) },
            help = "Project type qualifier.",
            default = suffix_default,
            allow_other = suffix_allow_other,
        })
    else
        context:prompt_text("Project Suffix:", "suffix_name", {
            cases = { Cases.programming(), Cases.fixed("suffix_title", Case.Title) },
            help = "Project type qualifier (e.g., service, library, cli).",
            default = suffix_default,
            optional = true,
        })
    end

    -- Derive the combined project name using the kebab-case variants
    -- produced by Cases.programming(). Always derive — overrides any
    -- stale value a caller may have pre-set.
    local prefix = context:get("prefix-name")
    local suffix = context:get("suffix-name")
    local project_name
    if suffix and suffix ~= "" then
        project_name = prefix .. "-" .. suffix
    else
        project_name = prefix
    end

    context:set("project_name", project_name, {
        cases = { Cases.programming(), Cases.fixed("project_title", Case.Title) },
    })

    return context
end

-- No finalize phase — project naming is pure context, no side effects.
function M.run(context)
    return M.prompt(context)
end

return M
