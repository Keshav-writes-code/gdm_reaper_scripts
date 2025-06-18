--[[
  @description Delete
  @about handle delete action for anything all over the arrange view in reaper according to my prefrences offcourse cuz reaper delete is just wierd
  @version 0.1
  @license MIT
  @author GDM
  @links
    GitHub repository https://github.com/Keshav-writes-code/gdm_reaper_scripts
]]

function deleteMediaItems()
	local itemSel_count = reaper.CountSelectedMediaItems(0)
	if itemSel_count == 0 then
		return false
	end
	for i = 0, itemSel_count - 1 do
		local item = reaper.GetSelectedMediaItem(0, 0)
		reaper.DeleteTrackMediaItem(reaper.GetMediaItemTrack(item), item)
	end
end

function msg(str)
	reaper.ShowConsoleMsg(str)
end
function sleep(a)
	local sec = tonumber(os.clock() + a)
	while os.clock() < sec do
	end
end

function deleteTrack()
	selTrk_count = reaper.CountSelectedTracks(0)

	if selTrk_count <= 1 then
		local x, y = reaper.GetMousePosition()
		local trk = reaper.GetTrackFromPoint(x, y)
		reaper.SetOnlyTrackSelected(trk)
		reaper.Main_OnCommand(40005, 0)
	elseif selTrk_count > 1 then
		reaper.Main_OnCommand(40005, 0)
	end
end

function deleteEnvelopePoints()
	local env, i = reaper.GetSelectedEnvelope(0), 0
	if not env then
		return
	end
	while i <= reaper.CountEnvelopePoints(env) - 1 do
		local _, _, _, _, _, isPointSelected = reaper.GetEnvelopePoint(env, i)
		if isPointSelected == true then
			reaper.DeleteEnvelopePointEx(env, -1, i)
			i = i - 1
		end
		i = i + 1
	end
end

function deleteEnvelope()
	local trkEnv = reaper.BR_GetMouseCursorContext_Envelope()
	local trkEnv_pointsCount, br_env = reaper.CountEnvelopePoints(trkEnv), reaper.BR_EnvAlloc(trkEnv, true)

	for i = 0, reaper.CountEnvelopePoints(trkEnv) - 1 do
		reaper.DeleteEnvelopePointEx(trkEnv, -1, 1)
	end
	local _, _, _, inLane, laneHeight, defaultShape = reaper.BR_EnvGetProperties(br_env)
	reaper.BR_EnvSetProperties(br_env, false, false, false, inLane, laneHeight, defaultShape, 1, nil)
	reaper.BR_EnvFree(br_env, true)
end

function RazorEditExists()
	for i = 0, reaper.CountTracks(0) - 1 do
		local track = reaper.GetTrack(0, i)
		local _, area = reaper.GetSetMediaTrackInfo_String(track, "P_RAZOREDITS", "", false)
		if area ~= "" then
			return true
		end
	end
end

function removeRazorEdit_content()
	reaper.Main_OnCommandEx(40697, 0, 0) --Remove items/tracks/envelope points (depending on focus)
end

---------------------------------------------------------------------------
----------------------------------MAIN-------------------------------------
---------------------------------------------------------------------------

function main()
	if RazorEditExists() then
		removeRazorEdit_content()
	else
		local window, windowSegment, windowSegment_details = reaper.BR_GetMouseCursorContext()
		local playState = reaper.GetPlayState()
		if window == "arrange" then
			if windowSegment == "track" then
				if windowSegment_details == "item" or windowSegment_details == "empty" then
					if reaper.GetCursorContext2(true) == 2 then
						deleteEnvelopePoints()
					else
						local wasSeccess = deleteMediaItems()
						if wasSeccess == false and playState <= 4 then
							deleteTrack()
						end
					end
				elseif windowSegment_details == "env_point" or windowSegment_details == "env_segment" then
					deleteEnvelopePoints()
				end
			elseif windowSegment == "envelope" then
				deleteEnvelopePoints()
			end
			reaper.UpdateArrange()
		elseif window == "tcp" or window == "mcp" then
			if windowSegment == "track" and playState <= 4 then
				deleteTrack()
			elseif windowSegment == "envelope" then
				deleteEnvelope()
			end
		end
	end
end

reaper.Undo_BeginBlock2(0)
reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock2(0, "GDM - Delete (Context Based)", 0)
