-- Key bindings as plain rows, { modifiers, key, press, data }, turned into
-- awful.key objects only at the end. awesome runs every binding that matches
-- a combo, so a host cannot replace a shared binding by adding another one;
-- it has to be dropped before it is created.

local awful = require("awful")
local gears = require("gears")

local M = {}

-- modifiers and key of a row as one string, independent of modifier order
local function combo(row)
  local mods = {}
  for _, mod in ipairs(row[1]) do
    table.insert(mods, mod)
  end
  table.sort(mods)
  table.insert(mods, row[2])
  return table.concat(mods, "+")
end

-- Merge lists of rows. A later row with the same modifiers and key replaces
-- an earlier one; a row whose press is false removes the binding.
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
    if row[3] then
      table.insert(merged, row)
    end
  end
  return merged
end

-- Create the awful.key objects of a list of rows.
function M.keys(rows)
  local keys = {}
  for _, row in ipairs(rows) do
    keys = gears.table.join(keys, awful.key(row[1], row[2], row[3], row[4]))
  end
  return keys
end

return M
