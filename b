-- Define the equation as a string
local equation = "8 + 4"

-- Evaluate the equation using load (or loadstring in Lua 5.1)
local func, err = load("return " .. equation)
if func then
    local result = func()
    print("Result:", result)
else
    print("Error:", err)
end

