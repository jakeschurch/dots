--@type AvanteProvider
local M = {}

-- Ollama for Avante
-- Ollama API Documentation https://github.com/ollama/ollama/blob/main/docs/api.md#generate-a-completion

M.api_key_name = ""
M.endpoint = "http://127.0.0.1:11434/api"
M.options = {
  num_ctx = 32768,
  temperature = 0,
}
M.model = "qwen2.5-coder:7b"

M.parse_response = function(data_stream, _, opts)
  if data_stream:match('"%[DONE%]":') then
    opts.on_complete(nil)
    return
  end
  if data_stream:match('"delta":') then
    ---@type OpenAIChatResponse
    local json = vim.json.decode(data_stream)

    if json.choices and #json.choices > 0 then
      -- Iterate through choices in reverse order
      for i = #json.choices, 1, -1 do
        local choice = json.choices[i]
        if
            choice.finish_reason == "stop"
            or choice.finish_reason == "eos_token"
        then
          opts.on_complete(nil)
        elseif choice.delta.content then
          if choice.delta.content ~= vim.NIL then
            opts.on_chunk(choice.delta.content)
          end
        end
      end
    end
  end
end

M.parse_stream_data = function(data, handler_opts)
  -- Parse the JSON data
  local json_data = vim.fn.json_decode(data)
  -- Check for stream completion marker first
  if json_data and json_data.done then
    handler_opts.on_complete(nil)   -- Properly terminate the stream
  end
  -- Process normal message content
  if json_data and json_data.message and json_data.message.content then
    -- Extract the content from the message
    local content = json_data.message.content
    -- Call the handler with the content
    handler_opts.on_chunk(content)
  end
end

M.parse_curl_args = function(self, prompt_opts)
  local options = {
    num_ctx = (self.options and self.options.num_ctx) or 4096,
    temperature = prompt_opts.temperature
        or (self.options and self.options.temperature)
        or 0,
  }

  return {
    url = M.endpoint .. "/chat",
    headers = {
      Accept = "application/json",
      ["Content-Type"] = "application/json",
    },
    body = {
      model = M.model,
      messages = require("avante.providers").copilot.parse_messages(
        prompt_opts
      ),
      options = options,
      stream = true,
    },
  }
end

return M
