#!/bin/lua

local Source = ""

local file = io.open(arg[1], "r")
if file ~= nil then
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
		elseif c == "\n" or c == "\t" and instring == false then
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
		elseif c == "]" and instring ~= true and inblock ~= true then
			arraydepth = arraydepth - 1
			if arraydepth == 0 then
				inarray = false
			end
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

local WedjatProgramVariables = {}
local WedjatUserCommands = {}

local WedjatProgramArguments = {}
for i = 2, #arg do
	table.insert(WedjatProgramArguments, arg[i])
end


local WedjatCoreCommands = {
	["define"] = function(arguments)
	end
}





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


printProgramCommands()
--[=[ Developer Debugging Functions ]=]--
