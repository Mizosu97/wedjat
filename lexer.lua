lexer = {}

local function getchar(string, i)
	return string.sub(string, i, i)
end

lexer.lex = function(program)
	local programdata = {}
	local i = 1
	for i, string.len(program) do
		local char = getchar(program, i)
		if char == " " then
			i = i + 1
		elseif char == "`" then
			i = i + 1
			local number = ""
			while getchar(program, i) ~= "`" do
				local digit = getchar(program, i)
				if (digit >= 0 and digit <= 9) or digit == "." then
					number = number .. digit
					i = i + 1
				else
					error("Invalid character in `number` value.")
				end
			end
			table.insert(programdata, {"NUMBER", number})
			i = i + 1
		elseif char == "@" then
			i = i + 1
			local variable = ""
			while getchar(program, i) ~= "@" do
			end
		end
	end
end

return lexer
