for i = 0, reaper.CountSelectedTracks2(0, false) -1 do
    local trk = reaper.GetSelectedTrack(0, i)
    local trk_mute = reaper.GetMediaTrackInfo_Value(trk, "B_MUTE")
    if trk_mute == 1 then 
        reaper.SetMediaTrackInfo_Value(trk, "B_MUTE", 0)
    else
        reaper.SetMediaTrackInfo_Value(trk, "B_MUTE", 1)    
    end
end

