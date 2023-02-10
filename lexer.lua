lexer = {}

local tokens = {}

local position = 0
local peek = 0

local numbers = "0123456789."
local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"

local function getchar(string, position)
	return string.sub(string, position, position)
end


local function maketoken(typ, value)
	table.insert(tokens, {typ, value})
end

lexer.lex = function(program)
	local position = 1
	local programlength = string.len(program)
	while position <= programlength do
		local char = getchar(program, position)
		if char == "\"" then
			local string = ""
			local peek = position + 1
			while getchar(program, peek) ~= "\"" do
				string = string .. getchar(program, peek)
				peek = peek + 1
			end
			maketoken("string", string)
			position = peek + 1
		elseif char == ":" then
			local variable = ""
			local peek = position + 1
			while getchar(program, peek) ~= ":" do
				variable = variable .. getchar(program, peek)
				peek = peek + 1
			end
			maketoken("variable", variable)
			position = peek + 1
		elseif char == "`" then
			local number = ""
			local peek = position + 1
			while getchar(program, peek) ~= "`" do
				number = number .. getchar(program, peek)
				peek = peek + 1
			end
			maketoken("number", number)
			position = peek + 1
		elseif char == "[" then
			local peek = position + 1
			while getchar(program, peek) ~= "]" do
				peek = peek + 1
			end
			position = peek + 1
		elseif char == "(" then
			maketoken("lparen", nil)
			position = position + 1
		elseif char == ")" then
			maketoken("rparen", nil)
			position = position + 1
		elseif char == "+" then
			maketoken("add", nil)
			position = position + 1
		elseif char == "-" then
			maketoken("sub", nil)
			position = position + 1
		elseif char == "*" then
			maketoken("mul", nil)
			position = position + 1
		elseif char == "/" then
			maketoken("div", nil)
			positon = position + 1
		elseif char == "=" then
			if getchar(program, position + 1) == "=" then
				maketoken("isequalto", nil)
			else
				maketoken("equals", nil)
			end
			position = position + 1
		elseif char == ">" then
			if getchar(program, position + 1) == "=" then
				maketoken("gthanorequals", nil)
			else
				maketoken("greaterthan", nil)
			end
			position = position + 1
		elseif char == "<" then
			if getchar(program, position + 1) == "=" then
				maketoken("lthanorequals", nil)
			else
				maketoken("lessthan", nil)
			end
			positon = position + 1
		else
			position = position + 1
		end
	end
	return tokens
end

return lexer
