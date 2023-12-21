--[[

	Author: @XnLogicaL (@CE0_OfTrolling)
	Licensed under the MIT License.

]]--

export type SignalType = {
	_connections: {RBXScriptConnection},
	_bindable: BindableEvent,
	Connect: (self: SignalType, _handler: (any) -> (any)) -> RBXScriptConnection,
	Once: (self: SignalType, _handler: (any) -> (any)) -> RBXScriptConnection,
	Fire: (self: SignalType, ...any) -> (),
	Wait: (self: SignalType) -> any,
	DisconnectAll: (self: SignalType) -> (),
	Destroy: (self: SignalType) -> (),
}

export type Signal = {
	_signals: {SignalType},
	new: () -> SignalType,
	DestroyAll: (self: Signal) -> ()
}

Signal = {
	_signals = setmetatable(Signal, {})
}
Signal.__index = Signal
Signal._signals.__index = Signal._signals

function Signal.new()
	local newSignal: SignalType
	newSignal = {
		_bindable = Instance.new("BindableEvent"),
		_connections = {},
		Connect = function(self: SignalType, _handler: (any) -> (any))
			local connection = self._bindable.Event:Connect(_handler)
			table.insert(self._connections, connection)
			return {
				Disconnect = function(self: RBXScriptConnection)
					local fromFind = table.find(newSignal._connections, self, 1)
					table.remove(newSignal._connections, fromFind)
					self:Disconnect()
					return nil
				end,
			}
		end,
		Once = function(self: SignalType, _handler: (any) -> (any))
			local fromFind
			local connection = self._bindable.Event:Once(function(...)
				table.remove(self._connections, fromFind)

				_handler(...)
			end)
			table.insert(self._connections, connection)
			fromFind = table.find(self._connections, connection, 1)
			return connection
		end,
		Fire = function(self: SignalType, ...: any)
			self._bindable:Fire(...)
		end,
		Wait = function(self: SignalType)
			return self._bindable.Event:Wait()
		end,
		DisconnectAll = function(self: SignalType)
			for _, v in self._connections do
				v:Disconnect()
			end
			table.clear(self._connections)
			return nil
		end,
		Destroy = function(self: SignalType)
			self:DisconnectAll()
			self._bindable:Destroy()
			table.clear(self)
			return nil
		end,
	}
	table.insert(newSignal, getmetatable(Signal))
	return newSignal
end

function Signal:DestroyAll()
	local self: Signal = self
	for _, sig: SignalType in getmetatable(self) do
		sig:Destroy()
	end
	return nil
end

return Signal :: Signal
