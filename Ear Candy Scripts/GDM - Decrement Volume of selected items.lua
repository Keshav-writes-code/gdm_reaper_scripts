--[[
  @description Decrement volume of selected items
  @about make the selected items volume go down like a fade out. Designed for drum hits that are very near to each other
  @version 0.1
  @license MIT
  @author GDM
  @links
    GitHub repository https://github.com/Keshav-writes-code/gdm_reaper_scripts
]]

---------------------------------Some Variables----------------------------------
--[[------------------------]]
local endingVolume = 0.001 -----------------------
---------------------------------------------------------------------------------
local pi = math.pi
local function outSine(t, b, c, d)
	return c * math.sin(t / d * (pi / 2)) + b
end

function main()
	local selItem_count = reaper.CountSelectedMediaItems(0)
	local first_selItem = reaper.GetSelectedMediaItem(0, 0)

	if not first_selItem then
		reaper.ShowMessageBox("       Select an item    ", "Error", 0)
		return
	end

	local first_selItem_vol = reaper.GetMediaItemInfo_Value(first_selItem, "D_VOL")

	for i = 0, selItem_count - 1 do
		local item = reaper.GetSelectedMediaItem(0, i)
		local vol = outSine(i, first_selItem_vol, -(first_selItem_vol - endingVolume), selItem_count)

		reaper.SetMediaItemInfo_Value(item, "D_VOL", vol)
	end
	reaper.UpdateArrange()
end

reaper.Undo_BeginBlock2(0)
reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock2(0, "Increment Velocities of Slected Notes", 0)
