local default_print = print
local default_warn = warn
local default_error = error 
local default_assert = assert

local function print(...)

   return default_print("[Mew]: "..tostring(...))
    
end

local function warn(...)

    return default_warn("[Mew]: "..tostring(...))
     
 end

local function error(...)

    return default_error("[Mew]: "..tostring(...))
     
 end

 local function assert(value ,...)

    return default_assert(value, "[Mew]: "..tostring(...))
     
 end

 return {

    assert = assert,
    error = error,
    print = print,
    warn = warn

 }