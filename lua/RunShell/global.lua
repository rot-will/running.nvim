local global = {}

global.shellpath = vim.fn.stdpath("data") .. "/shells"
global.shell = {}
global.default = 0
global.prefix_key = nil
global.windows = {
  config = {
    height = 10,
  }
}
global.default_shell = { "/bin/bash" }
return global
