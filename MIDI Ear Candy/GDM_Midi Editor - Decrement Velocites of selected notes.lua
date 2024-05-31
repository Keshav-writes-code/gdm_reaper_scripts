---------------------------------Some Variables----------------------------------
--[[------------------------]] local endingVelocity = 1 -----------------------
---------------------------------------------------------------------------------
local pi = math.pi

local function outSine(t, b, c, d)
  return c * math.sin(t / d * (pi / 2)) + b
end

function main()
    --to count selectd events
    local midieditor = reaper.MIDIEditor_GetActive()
    local take = reaper.MIDIEditor_GetTake(midieditor)
    local _,notecnt,_,_ = reaper.MIDI_CountEvts(take)
    
    --To get last selected midi note velocity
    local firstSelNote_velocity
    for i = 0, notecnt do
        local _, sel, _, _, _, _, _, vel = reaper.MIDI_GetNote(take, i);
        if sel == true then
            firstSelNote_velocity = vel
            break
        end
    end
    
    --to find the selected notes count
    local selNotesNumb = 0
    for i = 0, notecnt do
        local _, sel = reaper.MIDI_GetNote(take, i)
        if sel == true then
            selNotesNumb = selNotesNumb + 1
        end
    end
    
    if selNotesNumb <= 1 then
       reaper.ShowMessageBox("Select more than 1 note", "To use me", 0)
       return 
    end
    
    --To set the velocities of the midi notes
    local i2 = 0
    local diffrenceInStartingAndEndingVel = firstSelNote_velocity - endingVelocity
    
    for i = 0, notecnt do
        local _, sel, _, _, _, _, _, vel = reaper.MIDI_GetNote(take, i);
        if sel ~= true then 
            goto continue
        end
        
        --in sine equation
        local velocity = math.ceil(outSine(i2, firstSelNote_velocity, -diffrenceInStartingAndEndingVel, selNotesNumb))
        i2 = i2 + 1
        
        if velocity > 127 then velocity = 127 end
        
        reaper.MIDI_SetNote(take,i,nil,nil,nil,nil,nil,nil,velocity)
        
        ::continue::
    end
end

reaper.Undo_BeginBlock2(0)
reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock2(0, "Increment Velocities of Slected Notes", 0)
