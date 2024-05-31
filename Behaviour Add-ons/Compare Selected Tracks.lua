for i = 0, reaper.CountSelectedTracks(0) -1 do
    local trk = reaper.GetSelectedTrack(0, i)
    if i % 2 == 0 then
        reaper.SetMediaTrackInfo_Value(trk, "B_MUTE", 0)
    else
        reaper.SetMediaTrackInfo_Value(trk, "B_MUTE", 1)
    end
end
