------------------------------------------------------------------------
--[[----------------]]local scrollAmt = 55 --in Pixels------------------
--[[----------------]]local trkMax = 3000 --In Pixels---------------------------
--[[----------------]]local trkMin = 37 --In Pixels---------------------------


function main()
    local x, y = reaper.GetMousePosition()
    local track, context = reaper.GetThingFromPoint(x, y)
    _,_,_,_,_,_,mouseScroll = reaper.get_action_context()

    if string.find(context, "tcp") or string.find(context, "arrange") then --for track

        if reaper.IsTrackSelected(track) == false then
            reaper.SetOnlyTrackSelected(track)
        end
        local currentHeight = reaper.GetMediaTrackInfo_Value(track, "I_TCPH")
        
        if mouseScroll > 0 then
            if currentHeight > trkMax then return end
            reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", currentHeight + scrollAmt)
        else
            if currentHeight < trkMin then return end
            reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", currentHeight - scrollAmt)    
        end

        reaper.TrackList_AdjustWindows(false)
        
    elseif string.find(context, "env") or string.find(context, "envelope") then --for envelopes
        reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_BR_SEL_ENV_MOUSE"), 0, 0) -- SWS/BR: Select envelope at mouse cursor
        local br_env = reaper.BR_EnvAlloc(reaper.GetSelectedEnvelope(0), false)
        local active, visible, armed, inLane, laneHeight, defaultShape, _, _, _, _, faderScaling = reaper.BR_EnvGetProperties(br_env, false)
        
        if mouseScroll > 0 then
            if laneHeight > 500 then return end
            reaper.BR_EnvSetProperties( br_env, 
                                              active, 
                                              visible, 
                                              armed, 
                                              inLane, 
                                              laneHeight + scrollAmt, 
                                              defaultShape, 
                                              faderScaling )
        else
            if laneHeight < 60 then return end
            reaper.BR_EnvSetProperties( br_env, 
                                              active, 
                                              visible, 
                                              armed, 
                                              inLane, 
                                              laneHeight - scrollAmt, 
                                              defaultShape, 
                                              faderScaling )
        end
        reaper.BR_EnvFree( br_env, true )
    elseif not track then
        
        local track = reaper.GetTrack(0, reaper.CountTracks(0)-1)
        
        local currentHeight = reaper.GetMediaTrackInfo_Value(track, "I_TCPH")
        reaper.SetOnlyTrackSelected(track)
        
        if mouseScroll > 0 then
            if currentHeight > 500 then return end
            reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", currentHeight + scrollAmt)
        else
            if currentHeight < 37 then return end
            reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", currentHeight - scrollAmt)    
        end
        
        reaper.TrackList_AdjustWindows(false)
    end
end
main()
