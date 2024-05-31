-------------------------Some Variables---------------------------

--[[---------------]]pluginName = "Crystalline (BABY Audio)"
--[[---------------]]pereset = "Full Wet"-----------------------------
--[[---------------]]decimalVol = 0.3-------------------------

------------------------------------------------------------------
----------------------Some Functions------------------------------
------------------------------------------------------------------

function removeSilence()
    function remove_silence()
    local Thresh_dB = -55;
    local Attack_Rel  = 0;
    
    local Fun,scr,dir,MB,Arc,Load = reaper.GetResourcePath()..'/Scripts/Archie-ReaScripts/Functions',select(2,reaper.get_action_context()):match("(.+)[\\/]"),
    reaper.GetResourcePath();package.path=Fun.."/?.lua"..";"..scr.."/?.lua"..";"..dir.."/?.lua"..";"..package.path;Load,Arc=pcall(require,"Arc_Function_lua");
    if not Load then reaper.MB('Missing file "Arc_Function_lua",\nDownload from repository Archie-ReaScript and put in\n'..Fun..'\n\n'..'Отсутствует '..
    'файл "Arc_Function_lua",\nСкачайте из репозитория Archie-ReaScript и поместите в \n'..Fun,"Error.",0)return end;
    if not Arc.VersionArc_Function_lua("2.8.5",Fun,"")then Arc.no_undo() return end;
    
        local CountSelItem = reaper.CountSelectedMediaItems(0);
        if CountSelItem == 0 then Arc.no_undo() return end;
        ---------------------------------------------------
    
        if not tonumber(Thresh_dB ) or Thresh_dB  < -150 or Thresh_dB  > 24   then Thresh_dB  = -80 end;
        if not tonumber(Attack_Rel) or Attack_Rel <  0   or Attack_Rel > 1000 then Attack_Rel =   0 end;
        local ValInDB = 10^(Thresh_dB/20);
        ----------------------------------
    
        local zeroPeak,item_Sp_Left,item_Sp,leftCheck,rightEdge,rightCheck,Undo;
    
        for i = CountSelItem-1,0,-1 do;
            local Selitem = reaper.GetSelectedMediaItem(0,i);
            local Track = reaper.GetMediaItem_Track(Selitem);
            -------------------------------------------
            local take = reaper.GetActiveTake(Selitem);
            local source = reaper.GetMediaItemTake_Source(take);
            local samples_skip = reaper.GetMediaSourceSampleRate(source)/100;-- обработается 100 сэмплов в секунду
            local CountSamples_AllChannels,
                  CountSamples_OneChannel,
                  NumberSamplesAllChan,
                  NumberSamplesOneChan,
                  Sample_min,
                  Sample_max,
                  TimeSample = Arc.GetSampleNumberPosValue(take,samples_skip,true,true,true);
                  ---------------------------------------------------------------------------
    
            for i = #TimeSample,1,-1 do;
    
                if Sample_max[i] < ValInDB and i ~= 1 then;
    
                    if not PosRight then PosRight = i end;
                    zeroPeak = (zeroPeak or 0) + 1;
    
                elseif Sample_max[i] >= ValInDB or i == 1 then;
    
                    if zeroPeak and zeroPeak >= 5 then;
    
                        if not TimeSample[PosRight-Attack_Rel] then TimeSample[PosRight-Attack_Rel] = 0   end;
                        if not TimeSample[i + 1 + Attack_Rel ] then TimeSample[i + 1 + Attack_Rel ] = 9^9 end;
    
                        if PosRight == #TimeSample then rightCheck = PosRight else rightCheck = PosRight-Attack_Rel end;
                        if i == 1 then leftCheck = i else leftCheck = i+1+Attack_Rel end;
    
                        if TimeSample[rightCheck] > TimeSample[leftCheck] then;
    
                            if i == 1 then;
                                item_Sp_Left = Selitem;
                            else;
                                item_Sp_Left = reaper.SplitMediaItem(Selitem,TimeSample[i+1+Attack_Rel]);
                            end;
                            ----
    
                            if not rightEdge then;
                                item_Sp = reaper.SplitMediaItem(item_Sp_Left,TimeSample[PosRight]);
                            else;
                                item_Sp = reaper.SplitMediaItem(item_Sp_Left,TimeSample[PosRight-Attack_Rel]);
                            end;
                            ----
                            ----------------------------------
                            Arc.DeleteMediaItem(item_Sp_Left);
    
                            if not Undo then;
                                reaper.Undo_BeginBlock();
                                Undo = "Active";
                            end;
                            --------------------
                        end;
                    end;
                    rightEdge = 1;
                    PosRight = nil;
                    zeroPeak = 0;
                end;
            end;
        end;
    
        if Undo then;
            reaper.Undo_EndBlock("Remove silence in selected media items (-60 db)",-1);
        else;
            Arc.no_undo();
        end;
    
        reaper.UpdateArrange();
    end
    
    function sort()
    local Length = 0.110
    
      local item_count = reaper.CountMediaItems(0)
      local focus_it = reaper.GetSelectedMediaItem(0, 0)
      --Bypass if there is no Value in "focus_it"
      if not focus_it then return end 
      local sel_track = reaper.GetMediaItem_Track(focus_it)
      it_numb = 0
      
      for i = 0, item_count - 1 do
        
        local focus_it = reaper.GetSelectedMediaItem(0, it_numb)
        --Bypass if there is no Value in "focus_it"
        if not focus_it then return end
        local it_len = reaper.GetMediaItemInfo_Value( focus_it, "D_LENGTH")
        
        if it_len < Length then
          reaper.DeleteTrackMediaItem(sel_track, focus_it)
          
        else  
          it_numb = it_numb + 1
        
        end  
      end
    end
    
    function fade()
    
    -----------------------------------
            Fade_length = 0.005
    -----------------------------------
    
      local item_count = reaper.CountSelectedMediaItems(0)
      
      for i = 0, item_count - 1 do
        local sel_item = reaper.GetSelectedMediaItem(0, i)
        
        reaper.SetMediaItemInfo_Value(sel_item, "D_FADEINLEN", Fade_length)
        reaper.SetMediaItemInfo_Value(sel_item, "D_FADEOUTLEN", Fade_length)
        
      end
    end
    
    function normalize()
    
      reaper.Main_OnCommandEx(40108, 0, 0)
      
    end
    
    function main()
    
      remove_silence()
      sort()
      fade()
    
    end
    
    main()
end
function unSelectAllTracks()
    local trk_count = reaper.GetNumTracks()
    local i = 0
    for i = 0, trk_count - 1 do
        local track = reaper.GetTrack(0, i)
        reaper.SetTrackSelected(track, false)    
    end
end

function getParentTrackChildernsNumb(tr)
    local folder_tr_depth = reaper.GetTrackDepth(tr)
    local tr_number = reaper.GetMediaTrackInfo_Value(tr, "IP_TRACKNUMBER")
    local count = 0
    for i=tr_number, reaper.CountTracks(0)-1 do
      local get_tr = reaper.GetTrack(0,i)
      local tr_depth = reaper.GetTrackDepth(get_tr)
      if tr_depth <= folder_tr_depth then
        break
      else
        count = count + 1
      end
    end
    
    return count
end

function checkForTrackName(trkNameToCheck, item, checkAllTracks)
    --declaring some variables
    local totalTrkCount = reaper.CountTracks(0)
    local exists = 0
    local trackWithTheName = 0
    
    if checkAllTracks == true then
        for i = 0, totalTrkCount - 1 do
            local trk = reaper.GetTrack(0, i)
            local _, trk_name = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0, i), "P_NAME", "", false)
            
            if trk_name == "Reverb" then 
                trackWithTheName = trk
                exists = 1
                break
            end
        end
        return exists, trackWithTheName
    end
    
    local hasParent = false
    local item_track = reaper.GetMediaItemTrack(item)
    local item_parentTrack = reaper.GetParentTrack(item_track)
    local item_parentTrack_trkNumber = 0
    local item_parentTrack_trackDepth = 0
    local isParent = false
    
    --if item track is a parent
    if reaper.GetMediaTrackInfo_Value(item_track, "I_FOLDERDEPTH") == 1 then
        item_parentTrack_trkNumber = reaper.GetMediaTrackInfo_Value(item_track, "IP_TRACKNUMBER")
        item_parentTrack_trackDepth = reaper.GetTrackDepth(item_track)
        isParent = true
        
    --If track has a Parent
    elseif item_parentTrack then
        hasParent = true
        item_parentTrack_trkNumber = reaper.GetMediaTrackInfo_Value(item_parentTrack, "IP_TRACKNUMBER")
        item_parentTrack_trackDepth = reaper.GetTrackDepth(item_parentTrack)
    end
    
    
    for i = item_parentTrack_trkNumber , totalTrkCount -1 do
      local trackInAttension = reaper.GetTrack(0, i)
      
      if i == item_parentTrack_trkNumber then
          firstTrackInAttention_trackDepth = reaper.GetTrackDepth(trackInAttension)
      end
      local trackInAttension_trackDepth = reaper.GetTrackDepth(trackInAttension)

      --if the Track is the last child of a folder then break
      if trackInAttension_trackDepth  == item_parentTrack_trackDepth then
        if hasParent == true or isParent == true then
            break
        end
      end
      
      --if a parent track is encountered when scaning
      if firstTrackInAttention_trackDepth ~= trackInAttension_trackDepth then
          goto continue
      end
      
      --If the Track name was found
      local _, trk_name = reaper.GetSetMediaTrackInfo_String(trackInAttension, "P_NAME", "", false)
      if trk_name == trkNameToCheck then
          
          --to break if the found track is muted
          if reaper.GetMediaTrackInfo_Value(trackInAttension ,"B_MUTE") == 0 then
              
              trackWithTheName = trackInAttension 
              exists = 1
          end
          break
      end
      ::continue::
    end
    return exists, trackWithTheName, isParent
end

function insertingANewTrack(sel_item)
    local newTrkName = "Reverse Reverb"
    local new_trk 
    local checkForTrackName, trackWithTheName, isParent = checkForTrackName(newTrkName, sel_item, false)
    local itemTrk = reaper.GetMediaItemTrack(sel_item)
    
    --Inserting a track
    local itemTrk_numb = reaper.GetMediaTrackInfo_Value(itemTrk, "IP_TRACKNUMBER")
    
    if isParent == true then
        reaper.InsertTrackAtIndex(itemTrk_numb, true)
        new_trk = reaper.GetTrack(0, itemTrk_numb)
    else
        reaper.InsertTrackAtIndex(itemTrk_numb -1, true)
        new_trk = reaper.GetTrack(0, itemTrk_numb -1)
    end
    
    
    if checkForTrackName == 0 then
        reaper.GetSetMediaTrackInfo_String(new_trk, "P_NAME", newTrkName, true)
        
        --Setting color for new track
        local R = 171
        local G = 147
        local B = 235
        reaper.SetMediaTrackInfo_Value(new_trk, "I_CUSTOMCOLOR", reaper.ColorToNative( R, G, B )|0x1000000)
    end

    return new_trk, itemTrk, checkForTrackName, trackWithTheName
end
-------------------------------------------------------------------------------------------------
-----------------------------------------------MAIN----------------------------------------------
-------------------------------------------------------------------------------------------------

function main() 
    reaper.Undo_BeginBlock2(0)
    
--Preparing some stuff
    local sel_item 
    if not reaper.GetSelectedMediaItem(0, 0) then 
        reaper.ShowMessageBox("       Select a Item      ", "Error", 0)
        return
    else
        sel_item = reaper.GetSelectedMediaItem(0, 0)
        sel_item2 = sel_item 
    end
    
    local selItem_track = reaper.GetMediaItemTrack(sel_item)
    
--If item is Midi 
    
    local isItemMidi = reaper.TakeIsMIDI(reaper.GetTake(sel_item, 0)) 
    
    reaper.PreventUIRefresh(1)
    
    if isItemMidi == true then
        reaper.SetOnlyTrackSelected(selItem_track)
        reaper.Main_OnCommandEx(40062, 0, 0) --Track: Duplicate tracks
        
        local duplicateTrack_trkNumb = reaper.GetMediaTrackInfo_Value(selItem_track, "IP_TRACKNUMBER")
        duplicateTrack = reaper.GetTrack(0, duplicateTrack_trkNumb - 1)
        
        -- to correct the selItem_track variable
        selItem_track = reaper.GetTrack(0, duplicateTrack_trkNumb)
        
        --to delete every item but the one that is selected
        local focusedMediaItem = reaper.GetTrackMediaItem(duplicateTrack, 0)
        local i2 = 0
        
        for i = 0, reaper.CountTrackMediaItems(duplicateTrack) - 1 do
            if sel_item ~= focusedMediaItem then 
                reaper.DeleteTrackMediaItem(duplicateTrack, focusedMediaItem)
            else 
              i2 = 1
            end
            focusedMediaItem = reaper.GetTrackMediaItem(duplicateTrack, i2)
        end
        
        sel_item = reaper.GetTrackMediaItem(duplicateTrack, 0)
        
        --To trim the midi item
        if reaper.GetMediaItemInfo_Value(sel_item, "D_LENGTH") > 0.2 then
            reaper.SplitMediaItem(sel_item, (reaper.GetMediaItemInfo_Value(sel_item , "D_POSITION") + 0.2))
            
            --to remove the second half of the item
            reaper.DeleteTrackMediaItem(duplicateTrack, reaper.GetTrackMediaItem(duplicateTrack, 1))
        end
        
        --to remove all receives drom track
        for i = 0, reaper.GetTrackNumSends(duplicateTrack, -1) do
            reaper.SNM_RemoveReceive(duplicateTrack, i)
        end
        
        --To freeze
        reaper.SetOnlyTrackSelected(duplicateTrack)
        reaper.Main_OnCommandEx(41223, 0, 0) -- Freeze
        sel_item = reaper.GetTrackMediaItem(duplicateTrack, 0)
    end
    
    
--To unlock if the the item is locked
    if reaper.GetMediaItemInfo_Value(sel_item, "C_LOCK") == 1 then
        reaper.SetMediaItemInfo_Value(sel_item, "C_LOCK", 0) 
    end
    
--to copy the item to a new track
    reaper.Main_OnCommandEx(40289, 0, 0) --Unselect all Items
    
    reaper.SetMediaItemSelected(sel_item, true)
    
    reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_BR_FOCUS_ARRANGE_WND"), 0, 0) -- Focus Arrange
    
    reaper.Main_OnCommandEx(40698, 0, 0) -- Copy selected items
    
--Inserting a new Track
    local new_trk, item_trk, doesThatTrackExists, trackWithTheName = insertingANewTrack(sel_item)
    
--Managing the Track Selections
    unSelectAllTracks()
    
--Duplicating the main item without moving the edit cursor position or arrange view
    local editCurPos = reaper.GetCursorPositionEx(0)
    local arrange_startTime, arrange_endTime = reaper.GetSet_ArrangeView2(0, false, 0, 0, 0, 0)
  
    reaper.Main_OnCommandEx(41295, 0, 0) -- Item: Duplicate items
    
    reaper.SetEditCurPos2(0, editCurPos, false, false)
    reaper.GetSet_ArrangeView2(0, true, 0, 0, arrange_startTime, arrange_endTime)
    
--To move the new item to the new track and position it correctly
    local copiedItem = reaper.GetSelectedMediaItem(0, 0)
    local selItem_position = reaper.GetMediaItemInfo_Value(sel_item, "D_POSITION")
    
    reaper.MoveMediaItemToTrack(copiedItem, new_trk)
    reaper.SetMediaItemInfo_Value(copiedItem, "D_POSITION", selItem_position)
        
--To remove the track unwanted midi track
    if isItemMidi == true then
        reaper.DeleteTrack(duplicateTrack)
        sel_item = reaper.GetTrackMediaItem(new_trk, 0)
    end
    
--To remove Silence from start
    removeSilence()
    
--To remove every item exept the first one
    if reaper.CountSelectedMediaItems(0) > 1 then
        for i = 1, reaper.CountSelectedMediaItems(0) - 1 do
            local sel_item = reaper.GetTrackMediaItem(new_trk, 1)
            reaper.DeleteTrackMediaItem(new_trk, sel_item)
        end
    end
        
--To split
    local item_length = reaper.GetMediaItemInfo_Value(sel_item, "D_LENGTH")
    local copiedItem = reaper.GetSelectedMediaItem(0, 0)
    local copiedItem_track = new_trk
    
    local copiedItem_length = reaper.GetMediaItemInfo_Value(copiedItem, "D_LENGTH")
    local copiedItem_position = reaper.GetMediaItemInfo_Value(copiedItem, "D_POSITION")
    
    if copiedItem_length > 0.2 then
        reaper.SplitMediaItem(copiedItem, (copiedItem_position + 0.2))
        
        --to remove the second half of the item
        local copiedItem_IpNumber = reaper.GetMediaItemInfo_Value(copiedItem, "IP_ITEMNUMBER")
        local copiedItem_secondHalf = reaper.GetTrackMediaItem(copiedItem_track, copiedItem_IpNumber +1)
        reaper.DeleteTrackMediaItem(copiedItem_track, copiedItem_secondHalf)
    end 
    
--To fade in and out the item
    reaper.SetMediaItemInfo_Value(copiedItem, "D_FADEINLEN", 0.050)
    reaper.SetMediaItemInfo_Value(copiedItem, "D_FADEOUTLEN", 0.050)
   
    reaper.PreventUIRefresh(-1)
    reaper.UpdateArrange()
    reaper.PreventUIRefresh(1)
        
--Adding the Reverb
    local result_addfx = reaper.TrackFX_AddByName(new_trk, pluginName, false, -1)
    
    --If the fx wasn't found
    if result_addfx == 0 then
        reaper.TrackFX_SetPreset(new_trk, 0, pereset)
        
        if pluginName == "Crystalline (BABY Audio)" then 
            reaper.TrackFX_SetParam(new_trk, 0, 30, 1)
        end
    else
        --add ReaVerbate
        reaper.TrackFX_AddByName(new_trk, "ReaVerbate (Cockos)", false, -1)
        
        --changing some parameters
        reaper.TrackFX_SetParam(new_trk, 0, 0, 1)
        reaper.TrackFX_SetParam(new_trk, 0, 1, 0)
        reaper.TrackFX_SetParam(new_trk, 0, 2, 0.95)
        reaper.TrackFX_SetParam(new_trk, 0, 3, 0.9)
        reaper.TrackFX_SetParam(new_trk, 0, 7, 0.01)
        
    end
    
--Freezing the track
    reaper.SetTrackSelected(new_trk, true)
    reaper.Main_OnCommandEx(41223, 0, 0) -- Freezes
    
    local freezed_media_item = reaper.GetTrackMediaItem(new_trk, 0)
    
    if freezed_media_item then
        if reaper.GetMediaItemInfo_Value(freezed_media_item, "C_LOCK") == 1 then
            reaper.SetMediaItemInfo_Value(freezed_media_item, "C_LOCK", 0)
        end
        reaper.SetMediaItemSelected(freezed_media_item, true)
    end
    reaper.Main_OnCommandEx(40108, 0, 0) -- Normalize
    reaper.Main_OnCommandEx(41051, 0, 0) -- Revrse
    --Now, we got a reverb item
    --freezed_media_item 
    
    
--If the that track exists
    if doesThatTrackExists == 1 then
        reaper.MoveMediaItemToTrack(freezed_media_item, trackWithTheName)
        reaper.DeleteTrack(new_trk)
        new_trk = trackWithTheName
    end

--Send the track to reverb
    local doesThatTrackExists2, trackWithTheName2 = checkForTrackName("Reverb", "", true)
    local _, newTrk_firstSendName = reaper.GetTrackSendName(new_trk, 0)
    
    --If the Reverb Track doesn't exists then do nothing
    if doesThatTrackExists2 == 1 and newTrk_firstSendName ~= "Reverb" then
        reaper.CreateTrackSend(new_trk, trackWithTheName2)
        reaper.SetTrackSendUIVol(new_trk, 0, 2.5, 0)
    end
    
--Volume Adjustment of the freezed item
    local item_trk_vol
    
    --The the selected item track is a parent
    if reaper.GetMediaTrackInfo_Value(selItem_track, "I_FOLDERDEPTH") == 1 then
        local firstChildOfParent = reaper.GetTrack(0, reaper.GetMediaTrackInfo_Value(selItem_track, "IP_TRACKNUMBER") + 1)
        item_trk_vol = reaper.GetMediaTrackInfo_Value(firstChildOfParent, "D_VOL")
        reaper.DeleteTrackMediaItem(selItem_track, sel_item2)
    else
        item_trk_vol = reaper.GetMediaTrackInfo_Value(selItem_track, "D_VOL")
    end
    reaper.SetMediaItemInfo_Value(freezed_media_item ,"D_VOL", item_trk_vol * decimalVol )
    
--Positioning the item
    local freezed_media_item_len = reaper.GetMediaItemInfo_Value(freezed_media_item, "D_LENGTH")
    if copiedItem_position < freezed_media_item_len then
        reaper.PreventUIRefresh(-1)
        reaper.SetEditCurPos2(0, 0, false, false)
        reaper.ShowMessageBox("So, you have to position the item Manually", "It is used close to the starting", 0)
    else
        reaper.SetMediaItemInfo_Value(
            freezed_media_item, "D_POSITION", 
            copiedItem_position - freezed_media_item_len + 0.2
        )
        local freezedMediaItem_pos = reaper.GetMediaItemInfo_Value(freezed_media_item, "D_POSITION")
        reaper.SetEditCurPos2(0, freezedMediaItem_pos + 3, false, false)
        reaper.PreventUIRefresh(-1)
    end--]]
    reaper.Undo_EndBlock2(0, "", 0)
end
main()

