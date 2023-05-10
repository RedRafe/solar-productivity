local function startsWith(inputstr, start) 
  return inputstr:sub(1, #start) == start 
end

local function multiplyStringValue(text, coefficient)
  if not text then return nil end
  local n = string.match(text, "%d+")
  local s = string.match(text, "%a+")
  return tostring(tonumber(n) * coefficient) .. s
end

return {
  msv = multiplyStringValue,
  starts_with = startsWith,
}