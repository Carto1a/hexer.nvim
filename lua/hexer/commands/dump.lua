local function dump()
  print("dump")
end

---@param args string[]
local function main(args)
  print(args)

  dump()
end

---@param arg_lead string
local function complete(arg_lead)
  return vim.fn.getcompletion(arg_lead, "file")
end

return {
  command = main,
  complete = complete
}
