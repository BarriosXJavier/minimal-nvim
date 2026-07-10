local bootstrap = require("plugins.bootstrap")
local specs = require("plugins.specs")

bootstrap.setup_environment()
bootstrap.register_autocmds()
bootstrap.install(specs)

require("plugins.tooling").setup()
require("plugins.editor").setup()
require("plugins.navigation").setup()
require("plugins.completion").setup()
require("plugins.terminal").setup()
require("plugins.ui").setup()
