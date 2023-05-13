-- Created by https://entertheduat.org

local file = io.open(arg[1], "r")
local contents = file:read("*all")

local tokens = lex(contents)
