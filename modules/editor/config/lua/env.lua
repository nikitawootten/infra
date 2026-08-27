if os.getenv("SSH_TTY") then
	local osc52 = require("vim.ui.clipboard.osc52")
	vim.g.clipboard = {
		name = "OSC 52",
		copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
		paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
	}
end

-- direnv.vim reapplies the pre-nvim environment on every DirChanged, dropping the
-- wrapper's runtimePkgs from PATH. Re-append (not prepend) so a devshell still wins.
local wrapper_path = vim.env.PATH or ""
vim.api.nvim_create_autocmd("User", {
	pattern = "DirenvLoaded",
	callback = function()
		local present = {}
		for entry in vim.gsplit(vim.env.PATH or "", ":", { trimempty = true }) do
			present[entry] = true
		end
		local missing = {}
		for entry in vim.gsplit(wrapper_path, ":", { trimempty = true }) do
			if not present[entry] then
				table.insert(missing, entry)
			end
		end
		if #missing > 0 then
			vim.env.PATH = vim.env.PATH .. ":" .. table.concat(missing, ":")
		end
	end,
})
