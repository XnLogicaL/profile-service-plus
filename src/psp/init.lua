local Players = game:GetService("Players")
local psp = {}
psp.__index = psp
psp._running = false
psp._profilestore = nil
psp._onplayeradded = nil
psp._onplayerleave = nil
psp._thread = nil
psp._issues = 0
psp.onprofileloaded = nil

local ProfileService = require(script.ProfileService)
local Exceptions = require(script.Exceptions)
local Profiles = require(script.Manager)
local Template = require(script.Template)

Exceptions.new_exception("AppNotRunningError")
Exceptions.new_exception("CrossServerCheckError")

function psp.setstore(name: string, template: {any})
	psp._profilestore = ProfileService.GetProfileStore(
		name,
		template or Template
	)
end

function psp.start()
	psp._running = true
	
	local start = tick()
	local function PlayerAdded(player)
		local profile = psp._profilestore:LoadProfileAsync(("Player_%s"):format(player.UserId))
		if profile ~= nil then
			profile:AddUserId(player.UserId) -- GDPR compliance
			profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
			profile:ListenToRelease(function()
				Profiles[player] = nil
				-- The profile could've been loaded on another Roblox server:
				player:Kick("Data could not be fetched.")
			end)
			if player:IsDescendantOf(Players) == true then
				Profiles[player] = profile
				-- A profile has been successfully loaded:
				psp.onprofileloaded(player, profile)
			else
				-- Player left before the profile loaded:
				profile:Release()
			end
		else
			Exceptions.raise("CrossServerCheckError", `Cross server check failed for {player.Name}`)
			Exceptions.catch("CrossServerCheckError", function() player:Kick() end)
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		psp._thread = task.spawn(PlayerAdded, player)
		psp._issues += 1
	end

	psp._onplayeradded = Players.PlayerAdded:Connect(PlayerAdded)
	psp._onplayerleave = Players.PlayerRemoving:Connect(function(player)
		local profile = Profiles[player]
		if profile ~= nil then
			profile:Release()
		end
	end)

	warn(("[psp] started in %sms"):format(math.floor(tick() - start) + 1), ("%s issue(s) detected"):format(psp._issues))
end

function psp.stop()
	if psp._running == false then
		Exceptions.raise("AppNotRunningError", "")
	end
	psp._running = false
	psp._onplayeradded:Disconnect()
	psp._onplayerleave:Disconnect()
	task.cancel(psp._thread)
end

return psp
