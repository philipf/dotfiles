-- Mason's jdtls launcher starts java via os.execvp with a JVM flag as argv[0].
-- A mise shim dispatches on argv[0], so it fails ("... is not a valid shim").
-- With JAVA_HOME set, the launcher resolves the real java binary and skips the shim.
return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    if (vim.env.JAVA_HOME or "") == "" and vim.fn.executable("mise") == 1 then
      local java_home = vim.trim(vim.fn.system({ "mise", "where", "java" }))
      if vim.v.shell_error == 0 and java_home ~= "" then
        vim.env.JAVA_HOME = java_home
      end
    end

    -- lspconfig ranks .git alongside mvnw/gradlew, ahead of pom.xml, so a
    -- standalone Maven project nested in a repo (e.g. poc/foo/pom.xml that the
    -- root pom doesn't list as a module) gets rooted at the repo root. jdtls
    -- then only imports the root pom and the nested sources resolve to the
    -- default package. Prefer wrapper/settings markers, then the nearest build
    -- file, and fall back to .git last.
    opts.root_dir = function(path)
      return vim.fs.root(path, {
        { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" },
        { "pom.xml", "build.gradle", "build.gradle.kts", "build.xml" },
        ".git",
      })
    end
  end,
}
