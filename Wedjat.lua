#!/bin/lua

local source = ""

local file = io.open(arg[1], "r")
if file ~= nil then
	source = file:read("*all")
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
		elseif c == " " and instring ~= true then
			if i == 1 then
				lc = c
				i = i + 1
			elseif lc == " " then
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

print(CleanJunk(source))
