-- Key bindings as plain rows, turned into awful.key objects only at the end.
-- A row is the argument table of awful.key:
--
--   { modifiers = { "Mod4" }, key = "p", on_press = function() ... end,
--     description = "...", group = "..." }
--
-- awesome runs every binding that matches a combo, so a host cannot replace a
-- shared binding by adding another one; it has to be dropped before it is
-- created.

local awful = require("awful")

local M = {}

-- modifiers and key (or keygroup) of a row as one string, independent of
-- modifier order
local function combo(row)
  local mods = {}
  for _, mod in ipairs(row.modifiers or {}) do
    table.insert(mods, mod)
  end
  table.sort(mods)
  table.insert(mods, row.key or row.keygroup)
  return table.concat(mods, "+")
end

-- Merge lists of rows. A later row with the same modifiers and key replaces
-- an earlier one; a row with on_press = false removes the binding.
function M.merge(...)
  local rows, index = {}, {}
  for _, list in ipairs({ ... }) do
    for _, row in ipairs(list) do
      local id = combo(row)
      if not index[id] then
        index[id] = #rows + 1
      end
      rows[index[id]] = row
    end
  end
  local merged = {}
  for _, row in ipairs(rows) do
    if row.on_press then
      table.insert(merged, row)
    end
  end
  return merged
end

-- Create the awful.key objects of a list of rows.
function M.keys(rows)
  local keys = {}
  for _, row in ipairs(rows) do
    table.insert(keys, awful.key(row))
  end
  return keys
end

return M
