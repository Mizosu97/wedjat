local lexer = {}
local tokens = {}

pos = 1
peekpos = pos + 1

local function getc(str)
	pos = pos + 1
	return string.sub(str, pos, pos)
end

local function peek(str)
	peekpos = peekpos + 1
	return string.sub(str, peekpos, peekpos)
end

local function maketoken(tokentype, datatype, value)
	table.insert(tokens, {tokentype, datatype, value})
end

local lexswitch = {
	["\""] = function(str)
		local tokenv = ""
		while true do
			local c = peek(str)
			if c ~= "\"" then
				tokenv = tokenv .. c
				peekpos = peekpos + 1
			else
				break
			end
		end
		maketoken("data", "string", tokenv)
		peekpos = peekpos + 1
		pos = peekpos - 1
	end
}

local function checker(c)
	if lexswitch[c] then 
		return true
	else
		return false
	end
end

lexer.lex = function(str)
	local strlen = string.len(str)
	while pos <= strlen do
		local c = getc(str)
		if checker(c) == true then
			lexswitch[c](str)
		end
		pos = pos + 1
		peekpos = pos + 1
	end
	return tokens
end

return lexer

