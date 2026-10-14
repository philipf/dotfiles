-- With `console = "integratedTerminal"` (nvim-jdtls' default for "Launch ..."
-- configs), nvim-dap runs the program as a job in a terminal buffer and leaves
-- that job running when the session ends, so <leader>dt only detaches the
-- debugger and the app (e.g. Spring Boot on :8080) keeps running.
-- Stop the session's terminal job when the session ends. jobstop() sends
-- SIGHUP/SIGTERM, so the JVM runs its shutdown hooks (Spring closes gracefully),
-- and the buffer keeps the output. Attach sessions have no terminal: no-op.
return {
  "mfussenegger/nvim-dap",
  optional = true,
  opts = function()
    local dap = require("dap")

    local function stop_terminal_job(session)
      local buf = session and session.term_buf
      if not (buf and vim.api.nvim_buf_is_valid(buf)) then
        return
      end
      local job = vim.b[buf].terminal_job_id
      if job and vim.fn.jobwait({ job }, 0)[1] == -1 then
        vim.fn.jobstop(job)
      end
    end

    dap.listeners.after.disconnect["stop_terminal_job"] = stop_terminal_job
    dap.listeners.after.event_terminated["stop_terminal_job"] = stop_terminal_job
  end,
}
