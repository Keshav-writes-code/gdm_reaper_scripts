--[[
  @description auto bypass for all plugins
  @about makes all plugins in the project auto bypass 
  @version 0.1
  @license MIT
  @author GDM
  @links
    GitHub repository https://github.com/Keshav-writes-code/gdm_reaper_scripts
]]

function main()
	trkCount = reaper.CountTracks(0)
	for i = 0, trkCount - 1 do
		trk = reaper.GetTrack(0, i)
		trkFxCount = reaper.TrackFX_GetCount(trk)
		for i2 = 0, trkFxCount do
			local _, isAutoBypass_on = reaper.TrackFX_GetNamedConfigParm(trk, i2, "force_auto_bypass")
			if isAutoBypass_on == "0" then
				reaper.TrackFX_SetNamedConfigParm(trk, i2, "force_auto_bypass", "1")
			end
		end
	end
end
main()
