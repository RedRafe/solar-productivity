-- STRING UTIL LIBRARY

-- ============================================================================

---@param inputstr string
---@param start string
local function startsWith(inputstr, start) 
  return inputstr:sub(1, #start) == start 
end

-- ============================================================================

---@param text string
---@param coefficient number
local function multiplyStringValue(text, coefficient)
  if not text then return nil end
  local n, _ = string.gsub(text, "%a", "")
  local s = string.match(text, "%a+")
  return tostring(tonumber(n) * coefficient) .. s
end

-- ============================================================================

---@param name string
local function find_base(name)
  return string.gsub(name, "^sp%-([1-9][0-9]?)%-", "")
end

-- ============================================================================

return {
  base = find_base,
  msv = multiplyStringValue,
  starts_with = startsWith,
}