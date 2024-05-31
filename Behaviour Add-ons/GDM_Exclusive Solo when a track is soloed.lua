function unsoloAllTracks()
    trkCount = reaper.CountTracks(0)
    for i = 0, trkCount - 1 do
        reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0, i), "I_SOLO", 0)
    end
end

function main()
    
    if reaper.GetCursorContext() ~= 0 then goto continue end
    x, y = reaper.GetMousePosition()
    track = reaper.GetTrackFromPoint(x, y)
    if not track or lastFocusedTrack == track then
        goto continue
    end
    reaper.PreventUIRefresh(1)
    if reaper.GetMediaTrackInfo_Value(track, "I_SOLO") > 0 then
        unsoloAllTracks()
        reaper.SetMediaTrackInfo_Value(track, "I_SOLO", 2)
        lastFocusedTrack = track
    end
    reaper.PreventUIRefresh(-1)
    ::continue::
    reaper.defer(main)
end

-----------------------------------------------

function setScriptState(set)
    local _, _, sectionID, cmdID = reaper.get_action_context()
    reaper.SetToggleCommandState(sectionID, cmdID, set or 0)
    reaper.RefreshToolbar2(sectionID, cmdID)
end

-----------------------------------------------

setScriptState(1)
main()
reaper.atexit(setScriptState)
