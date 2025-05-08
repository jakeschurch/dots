return {
	["codebase"] = require("vectorcode.integrations").codecompanion.chat.make_slash_command(),
	["git_files"] = require("plugin.llm.codecompanion.slash_commands.git_files"),
	["agent_mode"] = require("plugin.llm.codecompanion.slash_commands.agent_mode"),
	["delete_session"] = require("plugin.llm.codecompanion.slash_commands.delete_session"),
	["dump_session"] = require("plugin.llm.codecompanion.slash_commands.dump_session"),
	["plan_mode"] = require("plugin.llm.codecompanion.slash_commands.plan_mode"),
	["restore_session"] = require("plugin.llm.codecompanion.slash_commands.restore_session"),
	["review_git_diffs"] = require("plugin.llm.codecompanion.slash_commands.review_git_diffs"),
	["review_merge_request"] = require("plugin.llm.codecompanion.slash_commands.review_merge_request"),
	["summarize_text"] = require("plugin.llm.codecompanion.slash_commands.summarize_text"),
	["thinking"] = require("plugin.llm.codecompanion.slash_commands.thinking"),
}
