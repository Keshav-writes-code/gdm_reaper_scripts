--[[
  @description enable rev delay
  @about make plugins online for reverb and delay send tracks that are usually set offline in my reaper project template
  @version 0.1
  @license MIT
  @author GDM
  @links
    GitHub repository https://github.com/Keshav-writes-code/gdm_reaper_scripts
]]

function main()
	for i = 0, reaper.CountTracks(0) - 1 do
		local trk = reaper.GetTrack(0, i)

		if reaper.GetTrackDepth(trk) == 0 then
			for i2 = 0, reaper.TrackFX_GetCount(trk) - 1 do
				if reaper.TrackFX_GetOffline(trk, i2) then
					reaper.TrackFX_SetOffline(trk, i2, false)
				end
			end
			if i > 0 then
				return
			end
		end
	end
end

main()
