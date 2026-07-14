local lazypath = vim.env.LAZY
if lazypath and lazypath ~= "" then
  vim.opt.rtp:prepend(lazypath)
  require("lazy_setup")
  require("polish")
  return
end

lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"

local function abort_bootstrap(message)
  vim.api.nvim_echo({ { message, "ErrorMsg" } }, true, {})
  if #vim.api.nvim_list_uis() > 0 then
    vim.fn.getchar()
    vim.cmd.quit()
  else
    vim.cmd("cquit 1")
  end
  return false
end

local function run_git(args)
  local result = vim.fn.system(args)
  if vim.v.shell_error ~= 0 then return nil, result end
  return result
end

local function locked_lazy_commit()
  local ok, lock = pcall(function()
    return vim.fn.json_decode(table.concat(vim.fn.readfile(lockfile), "\n"))
  end)
  local commit = ok and lock["lazy.nvim"] and lock["lazy.nvim"].commit
  if type(commit) ~= "string" or #commit ~= 40 or not commit:match("^%x+$") then
    return nil, "lazy-lock.json must contain a 40-character hexadecimal lazy.nvim commit"
  end
  return commit:lower()
end

local function ensure_lazy()
  local commit, lock_error = locked_lazy_commit()
  if not commit then return abort_bootstrap(lock_error) end

  local bootstrapped = false
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    bootstrapped = true
    local _, clone_error = run_git({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    })
    if clone_error then
      vim.fn.delete(lazypath, "rf")
      return abort_bootstrap("Error cloning lazy.nvim:\n" .. clone_error)
    end
  end

  local head, head_error = run_git({ "git", "-C", lazypath, "rev-parse", "HEAD" })
  if not head_error and vim.trim(head):lower() == commit then return true end

  local _, object_error = run_git({ "git", "-C", lazypath, "cat-file", "-e", commit .. "^{commit}" })
  if object_error then
    local _, fetch_error = run_git({ "git", "-C", lazypath, "fetch", "--depth=1", "origin", commit })
    if fetch_error then
      if bootstrapped then vim.fn.delete(lazypath, "rf") end
      return abort_bootstrap("Error fetching locked lazy.nvim commit:\n" .. fetch_error)
    end
  end

  local _, checkout_error = run_git({ "git", "-C", lazypath, "checkout", "--detach", commit })
  if checkout_error then
    if bootstrapped then vim.fn.delete(lazypath, "rf") end
    return abort_bootstrap("Error checking out locked lazy.nvim commit:\n" .. checkout_error)
  end

  head, head_error = run_git({ "git", "-C", lazypath, "rev-parse", "HEAD" })
  if head_error or vim.trim(head):lower() ~= commit then
    if bootstrapped then vim.fn.delete(lazypath, "rf") end
    return abort_bootstrap("lazy.nvim HEAD does not match the commit locked in lazy-lock.json")
  end

  return true
end

if not ensure_lazy() then return end

vim.opt.rtp:prepend(lazypath)
require("lazy_setup")
require("polish")
