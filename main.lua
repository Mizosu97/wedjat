-- Created by https://entertheduat.org

local lexer = dofile("/home/mizosu/vscodium/wedjat/lexer.lua")

local file = io.open(arg[1], "r")
local contents = file:read("*all")

local tokens = lexer.lex(contents)


local tokenindex = 1
while tokenindex <= #tokens do
	local token = tokens[tokenindex]
	print(string.format("\nToken %d:\nToken type: %s\nData type: %s\nValue: %s", tokenindex, token[1], token[2], token[3]))
end
