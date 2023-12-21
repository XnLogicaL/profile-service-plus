--[[

	Author: @XnLogicaL (@CE0_OfTrolling)
	Licensed under the MIT License
	
	A Lua implementation of python's exceptions

]]--

export type module = {
	_exception_raised: RBXScriptSignal,
	exceptions: {() -> ()},
	raise: (__exception: string?, ...string) -> (),
	catch: (__exception: string?, __exception_handler: (any) -> (any)) -> (),
	new_exception: (__body: string) -> ()
}

local Signal = require(script.Parent.BestSignal)
local assert = function(condition: boolean, _handler: (any) -> (any))
	if condition == false or condition == nil then
		_handler()
	end
end

module = {
	_exception_raised = Signal.new(),
	exceptions = {
		["UnregisteredExceptionError"] = function() return "UnregisteredExceptionError" end,
		["BaseException"] = function() return "BaseException" end,
		["LogicError"] = function() return "LogicError" end,
		["TypeError"] = function() return "TypeError" end,
		["ValueError"] = function() return "ValueError" end,
		["AssertionError"] = function() return "AssertionError" end,
		["AttributeError"] = function() return "AttributeError" end,
		["ArithmeticError"] = function() return "ArithmeticError" end,
		["IndexError"] = function() return "IndexError" end,
		["KeyError"] = function() return "KeyError" end,
		["NameError"] = function() return "NameError" end,
		["RecursionError"] = function() return "RecursionError" end,
		["RefrenceError"] = function() return "RefrenceError" end,
		["RunTimeError"] = function() return "RunTimeError" end,
	},
	raise = function(__exception: string?, ...)
		local self: module = module
		assert(type(__exception) == "string", self.raise("TypeError", ("expected string, got %s"):format(type(__exception))))
		assert(self.exceptions[__exception] ~= nil, self.raise("UnregisteredExceptionError", "could not index exception"))
		self._exception_raised:Fire(__exception)
		return error(("raised exception %s: %s"):format(__exception, ...))
	end,
	catch = function(__exception: string?, __exception_handler: (any) -> (any)) -- IMPORTANT: only catches thrown exceptions.
		local self: module = module
		assert(type(__exception) == "string", self.raise("TypeError", ("expected string, got %s"):format(type(__exception))))
		self._exception_raised:Connect(function(_exception)
			if _exception == __exception then
				__exception_handler()
			end
		end)
	end,
	new_exception = function(__body: string)
		local self: module = module
		assert(type(__body) == "string", self.raise("TypeError", ("expected string, got %s"):format(type(__body))))
		self.exceptions[__body] = function()
			return __body
		end
	end,
}

return module
