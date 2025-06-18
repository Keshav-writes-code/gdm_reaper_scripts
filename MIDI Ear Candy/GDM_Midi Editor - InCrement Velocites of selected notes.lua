--[[
  @description Increment velocities of selected notes
  @about make the selected notes velocites go loud from quite like a fade in. Designed for drum hits that are very near to each other
  @version 0.1
  @license MIT
  @author GDM
  @links
    GitHub repository https://github.com/Keshav-writes-code/gdm_reaper_scripts
]]

---------------------------------Some Variables----------------------------------
--[[------------------------]]
local startingVelocity = 1 -----------------------
---------------------------------------------------------------------------------
local pi = math.pi
local function inSine(t, b, c, d)
	return -c * math.cos(t / d * (pi / 2)) + c + b
end

function main()
	--to count selectd events
	local midieditor = reaper.MIDIEditor_GetActive()
	local take = reaper.MIDIEditor_GetTake(midieditor)
	local _, notecnt, _, _ = reaper.MIDI_CountEvts(take)

	--To get last selected midi note velocity
	local lastSelNote_velocity
	local selNotesNumb = 0

	for i = 0, notecnt do
		local _, sel, _, _, _, _, _, vel = reaper.MIDI_GetNote(take, i)
		if sel == true then
			lastSelNote_velocity = vel
			selNotesNumb = selNotesNumb + 1
		end
	end

	if selNotesNumb <= 1 then
		reaper.ShowMessageBox("Select more than 1 note", "To use me", 0)
		return
	end

	if lastSelNote_velocity < 55 then
		--startingVelocity = 1
	end

	--To set the velocities of the midi notes
	local i2 = 1
	local diffrenceInEndingAndStartingVel = lastSelNote_velocity - startingVelocity
	local pi = math.pi

	for i = 0, notecnt do
		local _, sel, _, _, _, _, _, vel = reaper.MIDI_GetNote(take, i)
		if sel ~= true then
			goto continue
		end

		--out Sine Equation
		local velocity = math.ceil(inSine(i2, startingVelocity, diffrenceInEndingAndStartingVel, selNotesNumb))

		i2 = i2 + 1

		if velocity > 127 then
			velocity = 127
		end

		reaper.MIDI_SetNote(take, i, nil, nil, nil, nil, nil, nil, velocity)

		::continue::
	end
end

reaper.Undo_BeginBlock2(0)
reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock2(0, "Increment Velocities of Slected Notes", 0)
