local lexer = dofile("./lexer.lua")

local function readfile(path)
	local file = io.open(path, "rb")
	if not file then
		error("Invalid file path.")
	end
	local program = file:read("*all")
	file:close()
	return program
end

local program = readfile(arg[1])

local tokens = lexer.lex(program)

for _,token in pairs(tokens) do
	print("Type: " .. token[1] .. "   Value: " .. token[2])
end
