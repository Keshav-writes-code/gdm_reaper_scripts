--[[
  @description Increment volume of selected items
  @about make the selected items volume go loud from quite like a fade in. Designed for drum hits that are very near to each other
  @version 0.1
  @license MIT
  @author GDM
  @links
    GitHub repository https://github.com/Keshav-writes-code/gdm_reaper_scripts
]]

---------------------------------Some Variables----------------------------------
--[[------------------------]]
local startingVolume = 0.001 -----------------------
---------------------------------------------------------------------------------
local pi = math.pi
local function inSine(t, b, c, d)
	return -c * math.cos(t / d * (pi / 2)) + c + b
end

function main()
	local selItem_count = reaper.CountSelectedMediaItems(0)
	local last_SelItem = reaper.GetSelectedMediaItem(0, selItem_count - 1)

	if not last_SelItem then
		reaper.ShowMessageBox("       Select an item    ", "Error", 0)
		return
	end

	local last_SelItem_vol = reaper.GetMediaItemInfo_Value(last_SelItem, "D_VOL")

	for i = 0, selItem_count - 1 do
		local item = reaper.GetSelectedMediaItem(0, i)
		local vol = inSine(i + 1, startingVolume, last_SelItem_vol - startingVolume, selItem_count)

		reaper.SetMediaItemInfo_Value(item, "D_VOL", vol)
	end
	reaper.UpdateArrange()
end

reaper.Undo_BeginBlock2(0)
reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock2(0, "Increment Velocities of Slected Notes", 0)
