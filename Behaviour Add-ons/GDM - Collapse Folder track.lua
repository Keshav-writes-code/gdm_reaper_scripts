--[[
  @description collapse folder track
  @about just collapses all folder track. work efficently by starting the search of the track under mouse
  @version 0.1
  @license MIT
  @author GDM
  @links
    GitHub repository https://github.com/Keshav-writes-code/gdm_reaper_scripts
]]

function main()
	for i = 0, reaper.CountSelectedTracks(0) - 1 do
		trk = reaper.GetSelectedTrack(0, i)

		if not trk then
			trk = reaper.BR_GetMouseCursorContext_Track()
		end

		local trk_folderCompact = reaper.GetMediaTrackInfo_Value(trk, "I_FOLDERCOMPACT")
		local _, _, secId, cmdId = reaper.get_action_context()

		if trk_folderCompact < 2 then
			reaper.SetMediaTrackInfo_Value(trk, "I_FOLDERCOMPACT", 2)
		else
			reaper.SetMediaTrackInfo_Value(trk, "I_FOLDERCOMPACT", 0)
		end
	end
end
reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
