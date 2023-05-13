local lexer = {}
local tokens = {}

pos = 1
peekpos = pos + 1

local function getc(str)
	return string.sub(str, pos, pos)
	pos = pos + 1
end

local function peek(str)
	return string.sub(str, peekpos, peekpos)
	peekpos = peekpos + 1
end

lexer.lex = function(str)
end

return lexer

