local prompt = [[
You are a senior staff engineer specializing in infrastructure and platform systems. Review the following RFC deeply and provide:

Summary (2-3 sentences)

What is the RFC proposing?

What problem is it solving?

Design Strengths

What aspects of the design, architecture, or approach are strong, well-justified, or elegant?

Design Weaknesses & Risks

What are the potential weaknesses, scalability concerns, operational risks, unclear assumptions, or security implications?

Implementation & Operational Concerns

Are there deployment, migration, reliability, observability, maintainability, or security issues that need addressing?

Suggested Improvements & Alternatives

What specific improvements, clarifications, or alternative approaches would strengthen this RFC?

Clarity & Communication

Is the RFC clearly structured and understandable?

Are there terms, diagrams, or explanations that should be added or clarified?

Respond in a structured bullet-point format under each heading. Think from the perspective of someone responsible for implementing, operating, and scaling this system in production reliably and securely.
]]

---@param chat CodeCompanion.Chat
local function callback(chat)
  local content = prompt
  chat:add_buf_message({
    role = "user",
    content = content,
  })
end

return {
  description = "Review RFC",
  callback = callback,
  opts = {
    contains_code = false,
  },
}
