--@type AvanteProvider
local M = {}

-- llama.cpp OpenAI-compatible API for Avante
-- llama.cpp serves OpenAI-compatible API at /v1/chat/completions

M["local"] = true
M.api_key_name = nil
M.endpoint = "http://127.0.0.1:11434/v1"
M.options = {
  num_ctx = 32768,
  temperature = 0,
}
M.model = "qwen2.5-coder-14b"

M.parse_response = function(data_stream, _, opts)
  if data_stream:match('"%[DONE%]":') then
    opts.on_complete(nil)
    return
  end
  if data_stream:match('"delta":') then
    ---@type OpenAIChatResponse
    local json = vim.json.decode(data_stream)

    if json.choices and #json.choices > 0 then
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
  local json_data = vim.fn.json_decode(data)
  if json_data and json_data.done then
    handler_opts.on_complete(nil)
  end
  if json_data and json_data.choices and #json_data.choices > 0 then
    local choice = json_data.choices[1]
    if choice.delta and choice.delta.content then
      handler_opts.on_chunk(choice.delta.content)
    end
    if choice.finish_reason == "stop" then
      handler_opts.on_complete(nil)
    end
  end
end

M.parse_curl_args = function(self, prompt_opts)
  local options = {
    num_ctx = (self.options and self.options.num_ctx) or 32768,
    temperature = prompt_opts.temperature
      or (self.options and self.options.temperature)
      or 0,
  }

  return {
    url = M.endpoint .. "/chat/completions",
    headers = {
      Accept = "application/json",
      ["Content-Type"] = "application/json",
    },
    body = {
      model = M.model,
      messages = require("avante.providers").copilot.parse_messages(
        prompt_opts
      ),
      max_tokens = options.num_ctx,
      temperature = options.temperature,
      stream = true,
    },
  }
end

return M
