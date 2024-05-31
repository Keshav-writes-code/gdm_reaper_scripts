function main()
    for i = 0, reaper.CountTracks(0) -1 do
        local trk = reaper.GetTrack(0, i)
        
        if reaper.GetTrackDepth(trk) == 0 then 

            for i2 = 0, reaper.TrackFX_GetCount(trk) -1 do
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
