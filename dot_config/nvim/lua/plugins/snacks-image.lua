return {
	"folke/snacks.nvim",
	opts = {
		image = {
			enabled = true,
			-- Resolve Obsidian-style embeds (`![[name.png]]`). Obsidian links images
			-- by filename and finds them anywhere in the vault (mostly the configured
			-- `Attachments/` folder), but snacks only looks relative to the note. This
			-- hook locates the vault (nearest `.obsidian` ancestor) and finds the file:
			-- Attachments/ first, then note-relative, then a vault-wide search.
			-- Returns nil for non-vault notes so normal relative resolution still works.
			resolve = function(file, src)
				-- leave URLs (e.g. ![](https://...)) untouched
				if src:match("^%w+://") then
					return src
				end
				-- strip Obsidian size/alias suffix: ![[img.png|300]]
				src = src:gsub("|.*$", "")

				local dir = vim.fs.dirname(file)
				local marker = vim.fs.find(".obsidian", { path = dir, upward = true, type = "directory" })[1]
				if not marker then
					return nil -- not in an Obsidian vault: use snacks' default resolution
				end
				local vault = vim.fs.dirname(marker)
				local name = vim.fs.basename(src)

				-- simple cache so scrolling/redraws don't re-search the vault
				local cache = vim.g._obsidian_img_cache or {}
				vim.g._obsidian_img_cache = cache
				local key = vault .. "\0" .. name
				if cache[key] ~= nil then
					return cache[key] ~= false and cache[key] or nil
				end

				local function exists(p)
					return p and vim.uv.fs_stat(p) and p or nil
				end
				local found = exists(vault .. "/Attachments/" .. name) -- configured attachment folder
					or exists(dir .. "/" .. src) -- note-relative
					or vim.fs.find(name, { path = vault, type = "file", limit = 1 })[1] -- anywhere in vault

				cache[key] = found or false
				return found
			end,
			doc = {
				-- Caps for the inline image, in editor columns/rows. The image is
				-- scaled to fit this box (preserving aspect). Raise for bigger
				-- diagrams; an inline image can't exceed the editor window's usable
				-- width (window minus the number/sign gutter).
				max_width = 100,
				max_height = 40,
			},
			-- Using default inline rendering with conceal left OFF (math only).
			-- Tried two alternatives, both rejected:
			--   * conceal for mermaid -> clips tall diagrams (overlay bug: renders
			--     full height for a frame, then collapses to the block height).
			--   * `doc.inline = false` (float/hover popup) -> works but the peek-on-
			--     hover UX was worse than always-on inline.
			-- So: inline, source visible above the diagram, full-height render.
			convert = {
				-- mermaid-cli (mmdc) renders via puppeteer/Chromium. Point it at the
				-- system chromium so it doesn't try to download its own bundled Chrome.
				-- Mirrors the snacks default args, with two changes:
				--   * `-p <puppeteer-config>` so mmdc uses system chromium.
				--   * `-s 3` instead of `{scale}` (the ~1.25 terminal scale) to
				--     OVERSAMPLE: render the diagram at ~3x so the source PNG has more
				--     pixels than the display area. The terminal then downscales it,
				--     which is crisp; the default scale upscaled a small PNG (blurry).
				--     Bump higher for sharper (and heavier) renders.
				mermaid = function()
					local theme = vim.o.background == "light" and "neutral" or "dark"
					return {
						"-i",
						"{src}",
						"-o",
						"{file}",
						"-b",
						"transparent",
						"-t",
						theme,
						"-s",
						"3",
						"-p",
						vim.fn.expand("~/.config/puppeteer-config.json"),
					}
				end,
			},
		},
	},
}
