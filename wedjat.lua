#!/bin/lua

local Source = ""

local file = io.open(arg[1], "r")
if file then
	Source = file:read("*all")
	file:close()
else
	os.exit()
end


local function CleanJunk(text)
	local final = ""

	local instring = false
	local inarray = false
	local c = ""
	local lc = ""
	local i = 1
	while i <= #text do
		c = string.sub(text, i, i)
		if c == "\"" and lc ~= "\\" then
			instring = not instring
			final = final .. c
			lc = c
			i = i + 1
		elseif c == "[" and instring ~= true then
			inarray = true
			final = final .. c
			lc = c
			i = i + 1
		elseif c == "]" and instring ~= true then
			inarray = false
			final = final .. c
			lc = c
			i = i + 1
		elseif c == " " and instring ~= true then
			if i == 1 or lc == " " or inarray == true then
				lc = c
				i = i + 1
			else
				lc = c
				i = i + 1
				final = final .. c
			end
		elseif c == "\n" or c == "\t" and instring ~= true then
			lc = c
			i = i + 1
		elseif c == ">" then
			if instring == false then
				local li = i
				local lch = ""
				while li <= #text do
					lch = string.sub(text, li, li)
					if lch == "\n" then
						lc = "\n"
						i = li + 1
						break
					end
					li = li + 1
				end
			end
		else
			final = final .. c
			lc = c
                        i = i + 1
		end
	end
	return final
end

local function FinalTrim(text)
	local final = ""

	local c = ""
	local i = 1
	while i <= #text do
		c = string.sub(text, i, i)
		if c == " " then
			i = i + 1
		else
			break
		end
	end

	final = string.sub(text, i, #text)

	i = #text
	while i >= 1 do
		c = string.sub(text, i, i)
		if c == " " then
			i = i - 1
		else
			break
		end
	end

	final = string.sub(final, 1, i)

	return final
end

local function SplitStatements(text)
	local sl = {}
	local cs = ""
	local instring = false
	local inblock = false
	local blockdepth = 0
	local c = ""
	local lc = ""
	local i = 1

	while i <= #text do
		c = string.sub(text, i, i)
		if c == "\"" and lc ~= "\\" then
			instring = not instring
			lc = c
			cs = cs .. c
		elseif c == "{" and instring ~= true then
			inblock = true
			blockdepth = blockdepth + 1
			lc = c
			cs = cs .. c
		elseif c == "}" and instring ~= true then
			blockdepth = blockdepth - 1
			if blockdepth == 0 then
				inblock = false
			end
			lc = c
			cs = cs .. c
		elseif c == ";" and instring ~= true and inblock ~= true then
			table.insert(sl, FinalTrim(cs))
			cs = ""
		else
			lc = c
			cs = cs .. c
		end
		i = i + 1
	end
	return sl
end

local dataTypeIdentifiers = {
	["\""] = "str",
	[":"] = "int",
	["*"] = "bol",
	["["] = "arr",
	["{"] = "blk",
	["("] = "var",
	["|"]  = "arg"
}
local function GetDataType(argument)
	local Id = string.sub(argument, 1, 1)
	if dataTypeIdentifiers[Id] ~= nil then
		return dataTypeIdentifiers[Id]
	else
		return "str"
	end
end

local function getInfo(statement)
	local argstart = 1
	local c = ""
	while argstart <= #statement do
		c = string.sub(statement, argstart, argstart)
		argstart = argstart + 1
		if c == " " then
			break
		end
	end

	local commandname = string.sub(statement, 1, argstart - 2)
	local arguments = {}
	local carg = ""

	local lc = ""
	local i = argstart
	local instring = false
	local inblock = false
	local inarray = false
	local arraydepth = 0
	local blockdepth = 0
	while i <= #statement do
		c = string.sub(statement, i, i)
		if c == "\"" then
			if lc ~= "\\" and inblock ~= true and inarray ~= true then
				instring = not instring
			end
			carg = carg .. c
		elseif c == "{" and instring ~= true and inarray ~= true then
			inblock = true
			blockdepth = blockdepth + 1
			carg = carg .. c
		elseif c == "}" and instring ~= true and inarray ~= true then
			blockdepth = blockdepth - 1
			if blockdepth == 0 then
				inblock = false
			end
			carg = carg .. c
		elseif c == "[" and instring ~= true and inblock ~= true then
			inarray = true
			arraydepth = arraydepth + 1
			carg = carg .. c
		elseif c == "]" and instring ~= true and inblock ~= true then
			arraydepth = arraydepth - 1
			if arraydepth == 0 then
				inarray = false
			end
			carg = carg .. c
		elseif c == " " then
			if inblock ~= true and instring ~= true and inarray ~= true then
				table.insert(arguments, {["Content"] = carg, ["Type"] = GetDataType(carg)})
				carg = ""
			else
				carg = carg .. c
			end
		else
			carg = carg .. c
		end
		lc = c
		i = i + 1
	end
	table.insert(arguments, {["Content"] = carg, ["Type"] = GetDataType(carg)})

	return {
		["CommandName"] = commandname,
		["Arguments"] = arguments
	}
end

local function formatStatements(statements)
	local formatted = {}

	for _,statement in ipairs(statements) do
		table.insert(formatted, getInfo(statement))
	end

	return formatted
end








local CleanSource = CleanJunk(Source)
local SuperCleanSource = FinalTrim(CleanSource)
local Statements = SplitStatements(SuperCleanSource)
local InstructionSheet = formatStatements(Statements)

local WedjatProgramVariables = {
	["__VER"] = {
		["Name"] = "__VER",
		["Type"] = "str",
		["Content"] = "__VER"
	}
}
local WedjatUserCommands = {}

local WedjatProgramArguments = {}
for i = 2, #arg do
	table.insert(WedjatProgramArguments, arg[i])
end


local WedjatCoreCommands = {
	["define"] = function(Arguments)
		if Arguments[1].Type ~= "str" or Arguments[2].Type ~= "str" then
			return
		end

		local variableName = Arguments[1].Content
		local variableType = Arguments[2].Content

		if WedjatProgramVariables[variableName] then
			return
		end

		if variableType ~= "str"
		and variableType ~= "int"
		and variableType ~= "arr"
		and variableType ~= "bol"
		and variableType ~= "blk"
		then
			return
		end

		WedjatProgramVariables[variableName] = {["Name"] = variableName, ["Type"] = variableType, ["Content"] = ""}
	end,
	["set"] = function(Arguments)
		if Arguments[1].Type ~= "str" then
			return
		end

		local variableName = Arguments[1].Content
		local variableObject
		if WedjatProgramVariables[variableName] == nil then
			return
		end
		variableObject = WedjatProgramVariables[variableName]

		if Arguments[2].Type ~= variableObject.Type then
			return
		end

		variableObject.Content = Arguments[2].Content
	end,
	["write"] = function(Arguments)
		for _,argument in ipairs(Arguments) do
			if argument.Type == "str" then
				if string.sub(argument.Content, 1, 1) == "\"" then
					io.write(string.sub(argument.Content, 2, #argument.Content - 1))
				else
					io.write(argument.Content)
				end
			elseif argument.Type == "int" or argument.Type == "bol" then
				io.write(string.sub(argument.Content, 2, #argument.Content - 1))
			end
		end
	end,
	["read"] = function(Arguments)
		if Arguments[1].Type ~= "str" then
			return
		end
		local variableName = Arguments[1].Content
		if WedjatProgramVariables[variableName] == nil then
			return
		end
		local variableObject = WedjatProgramVariables[variableName]
		if variableObject.Type ~= "str" then
			return
		end
		variableObject.Content = tostring(io.read("*l"))
	end,
	["type"] = function(Arguments)
		if WedjatProgramVariables[Arguments[1].Content] == nil or WedjatProgramVariables[Arguments[1].Content].Type ~= "str" or Arguments[2] == nil then
			return
		end

		WedjatProgramVariables[Arguments[1].Content].Content = Arguments[2].Type
	end
}

local function runCommand(command)
	local CommandName = command.CommandName
	local Arguments = command.Arguments
	for _,argument in pairs(Arguments) do
		if argument.Type == "var" then
			argument.Content = WedjatProgramVariables[string.sub(argument.Content, 2, #argument.Content - 1)].Content
			argument.Type = GetDataType(argument.Content)
		end
	end

	if WedjatCoreCommands[CommandName] ~= nil then
		WedjatCoreCommands[CommandName](Arguments)
	end
end



--[=[ Developer Debugging Functions ]=]--

local function printStatements()
	local i = 1
	for _,s in pairs(Statements) do
		print(i .. " | " .. s)
		i = i + 1
	end
end

local function printProgramCommands()
	local ic = 1
	for _,i in ipairs(InstructionSheet) do
		print("Command " .. ic .. ": " .. i.CommandName)
		local ai = 1
		for _,a in ipairs(i.Arguments) do
			print("    Arg" .. ai .. " (type " .. a.Type .. ") | " .. a.Content)
			ai = ai + 1
		end
		ic = ic + 1
		print(" ")
	end
end


-- printProgramCommands()
--[=[ Developer Debugging Functions ]=]--



for _,i in ipairs(InstructionSheet) do
	runCommand(i)
end
