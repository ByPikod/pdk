local pi = pi
local MsgC = MsgC

--- @field prefix string Log level (error, info etc.)
--- @field prefix_color Color Prefix color
--- @field message_color Color Message color
--- @field addon string Addon name
pi.LOG_INFO = pi.LOG_INFO or {

	prefix = "INFO",
	prefix_color = Color( 0, 255, 234 ),
	message_color = Color( 64, 255, 73 ),
	addon = "PDK"

}

--- @field prefix string Log level (error, info etc.)
--- @field prefix_color Color Prefix color
--- @field message_color Color Message color
--- @field addon string Addon name
pi.LOG_ERROR = pi.LOG_ERROR or {

	prefix = "ERROR",
	prefix_color = Color( 0, 255, 234 ),
	message_color = Color( 255, 0, 0 ),
	addon = "PDK"

}

if CLIENT then

	pi.LOG_INFO.prefix_color = Color( 247, 255, 92 )
	pi.LOG_ERROR.prefix_color = Color( 247, 255, 92 )

end

--- Print a colored text that have your addon's name in its prefix.
--- @param text string Your text.
--- @param level table Your log table.
--- @see pi.LOG_ERROR
--- @see pi.LOG_INFO
--- @return nil
function pi.print( text, level )

	level = level or pi.LOG_INFO
	MsgC( level.prefix_color, level.addon, " [", level.prefix, "]: ", level.message_color, text, "\n" )

end