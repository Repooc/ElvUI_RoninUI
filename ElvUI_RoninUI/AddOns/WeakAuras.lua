local E = unpack(ElvUI)
local LibDeflate = E.Libs.Deflate
local LibSerialize = LibStub('LibSerialize', true)
local _, Engine = ...

Engine.WeakAuras = {}

local weakAuras = Engine.WeakAuras
local hexElvUIBlue = '|cff1785d1'

function weakAuras:getStringInfo(dataString)
	if not dataString then Engine:Print('No aura string provided.') return nil end
	local _, _, encodeVersion, encoded = dataString:find('^(!WA:%d+!)(.+)$')

	if encodeVersion then
		encodeVersion = tonumber(encodeVersion:match('%d+'))
	else
		encoded, encodeVersion = dataString:gsub('^%!', '')
	end

	local decoded
	if encodeVersion > 0 then
	  decoded = LibDeflate:DecodeForPrint(encoded)
	else
		return nil
	end

	local decompressed = LibDeflate:DecompressDeflate(decoded)
	if not decompressed then
		Engine:Print('Failed to decompress the WeakAura string.')
		return nil
	end

	local success, deserialized
	if encodeVersion > 1 then
		success, deserialized = LibSerialize:Deserialize(decompressed)
	end
	if not success then
		Engine:Print('Failed to deserialize the WeakAura string.')
		return nil
	end

	return deserialized.wagoID, deserialized.d, deserialized.c
end

function weakAuras:doesAuraExist(dataString)
	if not E:IsAddOnEnabled('WeakAuras') then return false end
	if not dataString then Engine:Print('No aura string provided.') return nil end
	local wagoID, primaryAuraData, _ = weakAuras:getStringInfo(dataString)
	if not wagoID and not primaryAuraData then Engine:Print('No wagoID or primaryAuraData found in the WeakAura string.') return false end

	if WeakAuras.GetData(primaryAuraData.id) or WeakAuras.IsAuraLoaded(primaryAuraData.id) then return true end

	for aura, data in pairs(WeakAurasSaved.displays) do
		if data.uid == primaryAuraData.uid then return true end

		if not wagoID then return false end
		if data.wagoID == wagoID then return true end
	end

	return false
end

function weakAuras:SetupProfile(profileString, profileID, callback)
	if not E:IsAddOnEnabled('WeakAuras') then Engine:Print(format('%s is |cffff3300disabled|r!', 'WeakAuras')) return end
	if not profileString then return Engine:Print('No profile string provided.') end

	if not WeakAuras.Import then Engine:Print('There was an error finding "WeakAuras.Import" function!') return end
	WeakAuras.Import(profileString, nil, function(complete, name)
		Engine:Print(format('WeakAura: %s import process has been %s.', name and format('%s%s|r', hexElvUIBlue, name) or 'The', complete and 'completed' or 'canceled/aborted'))
		PlaySound(888)
		if callback and type(callback) == 'function' then callback(profileID) end
	end)
end
