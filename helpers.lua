local XLoot = select(2, ...)
local buffer, print = {}, print

local table_insert, table_concat, string_format = table.insert, table.concat, string.format

local coin_table = {
	{ GOLD_AMOUNT, 0, "ffd700" },
	{ SILVER_AMOUNT, 0, "c7c7cf" },
	{ COPPER_AMOUNT, 0, "eda55f" }
}
for i,v in ipairs(coin_table) do
	v[4] = string_format("|cff%s%s|r", v[3], v[1])
end
function XLoot.CopperToString(copper)
	coin_table[1][2] = floor(copper / 10000)
	coin_table[2][2] = mod(floor(copper / 100), 100)
	coin_table[3][2] = mod(copper, 100)

	local buffer = wipe(buffer)
	for i,v in ipairs(coin_table) do
		local n = v[2]
		if n and n > 0 then
			table_insert(buffer, string_format(v[4], n))
		end
	end

	return table_concat(buffer, ", ")
end

local tooltip = CreateFrame('GameTooltip', 'XLootTooltip', UIParent, 'GameTooltipTemplate')
tooltip:SetOwner(UIParent, "ANCHOR_NONE")

function XLoot.GetItemBindType(link)
	tooltip:ClearLines()
	tooltip:SetHyperlink(link)
	local value = (GetCVar('colorblindMode') == '1' and XLootTooltipTextLeft4 or XLootTooltipTextLeft3):GetText()
	if value == ITEM_BIND_ON_PICKUP then
		return 'pickup'
	elseif value == ITEM_BIND_ON_EQUIP then
		return 'equip'
	elseif value == ITEM_BIND_ON_USE then
		return 'use'
	end
end

function XLoot.CanEquipItem(link)
	if not IsEquippableItem(link) then
		return false
	end
	tooltip:ClearLines()
	tooltip:SetHyperlink(link)
	for i=2, 5 do
		local line = _G["XLootTooltipTextRight"..i]
		if line and line:GetText() then
			local r, g, b = line:GetTextColor()
			local lr, lg, lb = _G["XLootTooltipTextLeft"..i]:GetTextColor()
			return (r > .8 and b > .8 and g > .8 and lr > .8 and lg > .8 and lb > .8) and true or false
		end
	end	
end
function XLoot.IsItemUpgrade(link)
	if not XLoot.CanEquipItem(link) then
		return false
	end
	local id = string.match(link, "item:(%d+)")
	if PawnIsItemIDAnUpgrade and id and PawnIsItemIDAnUpgrade(id) then
		return true
	end
	return false
end
-- Tack role icon on to player name and return class colors
local white = { r = 1, g = 1, b = 1 }
local dimensions = {
	HEALER = '48:64',
	DAMAGER = '16:32',
	TANK = '32:48'
}
function XLoot.FancyPlayerName(name, class, opt)
	local c = RAID_CLASS_COLORS[class] or white
	local role = UnitGroupRolesAssigned(name)
	local short, realm = UnitName(name)
	if short then
		name = short
	end
	if realm and realm ~= "" then
		name = name.." *"
	end
	if role ~= 'NONE' and opt.role_icon then
		name = string_format('\124TInterface\\LFGFRAME\\LFGROLE:12:12:-1:0:64:16:%s:0:16\124t%s', dimensions[role], name)
	end
	return name, c.r, c.g, c.b
end

--@do-not-package@
-- Debug
local AC = LibStub('AceConsole-2.0', true)
if AC then print = function(...) AC:PrintLiteral(...) end end
--@end-do-not-package@
