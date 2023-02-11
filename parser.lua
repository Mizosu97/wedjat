parser = {}

local token_index = 1
local tokenslen = 0

local function gettoken(tokens, index)
    return tokens[index]
end

parser.parse = function(tokens)
    for _,token in pairs(tokens) do
        tokenslen = tokenslen + 1
    end
end
   

return parser