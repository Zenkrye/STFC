-- Ankulua
TIMEOUT = 3
SIMILAR = 0.85
WIDTH = 1920
HEIGHT = 1080

--Sets root folder structure(so that it runs from whatever folder your script is ran from.
ROOT = scriptPath()

--Sets a custom path for my images folder, make sure your imagename.png is in yoyr images folder
DIR_IMAGES = ROOT .. "Images"
setImagePath(DIR_IMAGES)

-- Ankulua settings
-- ---------------------------------------
Settings:setCompareDimension(true, WIDTH)
Settings:setScriptDimension(true, WIDTH)
Settings:set("AutoWaitTimeout", TIMEOUT)
Settings:set("MinSimilarity", SIMILAR)

--Initialized as 0 to start, I update these manually throughout the script upon action completion. Only showing these because my function calls for it
TARGETS = 0
ATTACKS = 0
REPAIRS = 0
DEATHS = 0
MINE = 0

img = {
	docks ={P = Pattern('Talla.png'), R = Region(450, 850, 1000, 180),},
	realta ={P = Pattern('Realta.png'), R = Region(450, 850, 1000, 180),},
	corvette ={P = Pattern('Corvette.png'), R = Region(450, 850, 1000, 180),},
	fortunate ={P = Pattern('Fortunate.png'), R = Region(450, 850, 1000, 180),},
	talla ={P = Pattern('talla.png'), R = Region(450, 850, 1000, 180),},
	Turas ={P = Pattern('Turas.png'), R = Region(450, 850, 1000, 180),},
	talla ={P = Pattern('Talla.png'), R = Region(450, 850, 1000, 180),},
	system ={P = Pattern('System.png'), R = Region(1765, 857, 150, 150),},
	emptycargo ={P = Pattern('EmptyCargo.png'), R = Region(0, 575, 130, 130),},
	repairhelp ={P = Pattern('RepairHelp.png'), R = Region(295, 965, 100, 100),},
	power ={P = Pattern('Power.png'), R = Region(135, 0, 130, 130),},
	hull ={P = Pattern('Hull20.png'), R = Region(0, 992, 240, 118),},
}

--color scheme & font size (size 8 font)
--setHighlightStyle (color, fill)
--setHighlightTextStyle (bgColor, textColor, textSize)
--setHighlightTextStyle(0x96666666, 16711680, 8)
setHighlightTextStyle(0x96666666, 0xf8ffffff, 6)

--These 3 lines are where your paint / debug info will be displayed on your screen
REG_PAINT_LINE1 = Region(1080, 10, 242, 34)
REG_PAINT_LINE2 = Region(1080, 43, 242, 34)
REG_PAINT_LINE3 = Region(1080, 76, 242, 34)

function paint(section)
    local seconds = StaTimer:check()
    REG_PAINT_LINE1:highlightOff()
    REG_PAINT_LINE2:highlightOff()
    REG_PAINT_LINE3:highlightOff()
    REG_PAINT_LINE1:highlight("Time Ran: " .. secondsToClock(seconds) .. "")
    REG_PAINT_LINE2:highlight("T: " .. TARGETS .. " A: " .. ATTACKS .. " R: " .. REPAIRS .. " D: " .. DEATHS .. " M: " .. MINE)
    if (cbDebug) then 
		REG_PAINT_LINE3:highlight("Debug Section: " .. section)
	else
		REG_PAINT_LINE3:highlight("Section: " .. section)
	end
end

--function to convert seconds to easier-to-read string:
function secondsToClock(seconds)
    local seconds = tonumber(seconds)
    if seconds <= 0 then
        return "00:00:00";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return hours..":"..mins..":"..secs
    end
end

function regionWaitMulti(target, seconds, debug, skipLocation, index, previousSnap, colorMatch)
    local timer = Timer()
    local match
    local length = table.getn(target)
    if (index > length or index <= 0) then
        index = 1
    end

    while (true) do
        --        for i, t in ipairs(target) do
        if (not previousSnap) then
            if (colorMatch) then
            	--print('Color')
                snapshotColor()
            else
                snapshot()
            end
        end
        usePreviousSnap(true)
        for i = index, length do
            local t = target[i]
            local image = t.target

            if ((t.region and (t.region):exists(image, 0)) or
                    (not t.region and exists(image, 0))) then -- check once
                usePreviousSnap(false)
                if (t.region) then
                    match = (t.region):getLastMatch()
                else
                    match = getLastMatch()
                end
                --            if (debug) then match:offset(0, -cutoutHeight):highlight(0.5) end
                return i, t.id, match
            end
        end
        index = 1
        if (skipLocation ~= nil) then click(skipLocation) end
        if (timer:check() > seconds) then
            usePreviousSnap(false)
            return -1, "__none__"
        end
    end
end

function zoomout()
	zoom(50, 350, 330, 350, 1200, 350, 350, 350, 300)
end

function DialogTrial()
	-- Give the user options
	dialogInit()
	addTextView("Settings")
--	newRow()
--	addTextView("   ")
--	addCheckBox("cbDebug", "Debug Highlights", false)
	newRow()
	addTextView("   ")
	addCheckBox("cbZoom", "Extended Zoom Enabled", false)
	newRow()
	addTextView("Select Actions")
	newRow()
	addTextView("   ")
	addCheckBox("cbClaim", "Claim Rewards", false)
	newRow()
--	addTextView("   ")
--	addCheckBox("cbHelp", "Help Alliance", false)
--	newRow()
	spinnerItems = {"NONE", "Realta", "Corvette", "Fortunate", "Phindra", "Turas", "Talla"}
	addTextView("Select Ship:  ")
	addSpinnerIndex("spFight", spinnerItems, "NONE")
--	addCheckBox("cbTravel", " Travel? ", false)
--	addTextView(" Travel(secs):  ")
--	addEditNumber("travSec", 30)
	newRow()
	addTextView("Hostiles to Target:  ")
	newRow()
--	addCheckBox("cbShields", "Wait for Shields", true)
	addCheckBox("cbHB", "Battleship", true)
	addCheckBox("cbHE", "Explorer", true)
	addCheckBox("cbHI", "Interceptor", true)
--	addCheckBox("cbHS", "Survey", true)
	newRow()
--	addTextView("Select Miner:  ")
--	addSpinnerIndex("spMine1", spinnerItems, "NONE")
--	newRow()
cbHelp = false
cbDebug = false
cbTravel = false
travSec = 60
cbShields = false
spMine1 = 1

dialogShowFullScreen("Star Trek Fleet Command")
	--dialogShow("Star Trek Fleet Command")
end

function DialogFull()
	-- Give the user options
	dialogInit()
	addTextView("Settings")
	newRow()
	addTextView("   ")
	addCheckBox("cbDebug", "Debug Highlights", false)
	newRow()
	addTextView("   ")
	addCheckBox("cbZoom", "Extended Zoom Enabled", false)
	newRow()
	addTextView("Select Actions")
	newRow()
	addTextView("   ")
	addCheckBox("cbClaim", "Claim Rewards", false)
	newRow()
	addTextView("   ")
	addCheckBox("cbHelp", "Help Alliance", false)
	newRow()
	siShips = {"NONE", "Realta", "Corvette", "Fortunate", "Phindra", "Turas", "Talla"}
	siActions = {"Fight", "Mine"}
	addTextView("Select Ship A:  ")
	addSpinnerIndex("spShipA", siShips, "NONE")
	addTextView("   ")
	addTextView("Action:  ")
	addSpinnerIndex("spActionA", siActions, "Fight")
	--addCheckBox("cbTravel", " Travel? ", false)
	newRow()
	addTextView("Select Ship B:  ")
	addSpinnerIndex("spShipB", siShips, "NONE")
	addTextView("   ")
	addTextView("Action:  ")
	addSpinnerIndex("spActionB", siActions, "Fight")
	--addCheckBox("cbTravel", " Travel? ", false)
	newRow()
	addTextView("Select Ship C:  ")
	addSpinnerIndex("spShipC", siShips, "NONE")
	addTextView("   ")
	addTextView("Action:  ")
	addSpinnerIndex("spActionC", siActions, "Fight")
	--addCheckBox("cbTravel", " Travel? ", false)
	newRow()
	addTextView("Hostiles to Target:  ")
	newRow()
	addCheckBox("cbShields", "Wait for Shields", true)
	addCheckBox("cbHB", "Battleship", true)
	addCheckBox("cbHE", "Explorer", true)
	addCheckBox("cbHI", "Interceptor", true)
	addCheckBox("cbHS", "Survey", true)
	newRow()
	dialogShowFullScreen("Star Trek Fleet Command")
	--dialogShow("Star Trek Fleet Command")
end

function randomSwipe()
	-- Create a random swipe to move around the map
	fromx = math.random(480, 1440)
	fromy = math.random(270, 810)
	tox = math.random(480, 1440)
	toy = math.random(270, 810)
	swipe(Location(fromx, fromy),  Location(tox, toy))
end

function resetApp()
	-- Kill app
	-- Launch App
	-- wait until opened
	killApp(star.trek.fleet.command.game)
	wait(5)
	startApp(star.trek.fleet.command.game)
	if not (Region(135, 0, 130, 130):exists('Power.png',120)) then
		return false
	end
	return true
end

function cleanup()
	paint('Cleanup')
  local clean = {
    { id = '1', target = 'GiftsBack.png', region = Region(0, 0, 120, 120), },
    { id = '2', target = 'Relaunch.png', region = Region(824, 741, 140, 120), },
    { id = '3', target = 'Collapse.png', region = Region(0, 180, 120, 320), },
    { id = '4', target = 'AdClose.png', region = Region(1688, 136, 130, 130), },
    { id = '5', target = 'AdClose.png', region = Region(1420, 64, 400, 400), },
    { id = '6', target = 'CordClose.png', region = Region(1580, 176, 90, 90), },
    { id = '7', target = 'ConfirmR.png', region = Region(959, 757, 80, 80), }, 
    { id = '8', target = 'CargoClose.png', region = Region(1535, 103, 80, 80), },
 }
	Exit = 0
	while (Exit == 0)
	do
		local id, tar, m = regionWaitMulti(clean, 1, cbDebug, nil, 1, false, false)
		if (id == -1) then
			if (Region(135, 0, 130, 130):exists('Power.png',3)) then
				Exit = 1
			end
		elseif (id ~= nil)  then
			if (id == 2) then
				wait(600) -- wait to relaunch
			end
			click(m)
			if (id == 6) then
				wait(3) -- wait to relaunch
				repairShip()
			end
			wait(2)
		end
	end
end

function helpally()
	paint('Help Allies')
  local clean = {
    { id = '4', target = 'HelpAll.png', region = Region(1164, 976, 80, 80), },
    { id = '5', target = 'AllyHelp.png', region = Region(1606, 339, 100, 100), },
  }

	Exit = 0
	while (Exit == 0)
	do
		local id, tar, m = regionWaitMulti(clean, 1, cbDebug, nil, 1, false, false)
		if (id == -1) then
			if (Region(135, 0, 130, 130):exists('Power.png',3)) then
				Exit = 1
			end
		elseif (id ~= nil)  then
			click(m)
			wait(2)
		end
	end
end

function claim()
	paint('Claim')
  local clean = {
    { id = '1', target = 'ClaimDone.png', region = Region(949, 900, 120, 120), },
    { id = '2', target = 'ClaimA.png', region = Region(230, 780, 1320, 120), },
    { id = '3', target = 'Claim.png', region = Region(1774, 329, 80, 80), },
    { id = '4', target = 'GiftsBack.png', region = Region(0, 0, 120, 120), },
  }

	Exit = 0
	while (Exit == 0)
	do
		local id, tar, m = regionWaitMulti(clean, 1, cbDebug, nil, 1, false, false)
		if (id == -1) then
			if (Region(135, 0, 130, 130):exists('Power.png',3)) then
				Exit = 1
			end
		elseif (id ~= nil)  then
			click(m)
			if (id == 4) then	Exit = 1	end
			wait(2)
		end
	end
end

function mine()
	paint('Mine')
	wait(3)
	if (MineTimer:check() > 30*60) then
		return true
	end
	return false
end

function reset()
	paint('Reset')
	wait(1)
	zoomout()
	zoomout()
	randomSwipe()
	return false
end

function travel(sys)
  local steps = {
    { id = '1', target = 'MapPin.png', region = Region(1738, 254, 130, 130), },
    { id = '2', target = 'Go.png', region = Region(928, 321, 180, 150), }, 
    { id = '3', target = 'Bookmarks.png', region = Region(1679, 737, 130, 130), },
    }

	paint('Travel')
	Region(1679, 737, 260, 130):highlight(1)
	if not Region(1679, 737, 260, 130):existsClick('Bookmarks.png', 5) then
		return true
	end
	if not Region(1738, 254, 130, 130):existsClick('MapPin.png', 5) then
		return true
	end
	img.power.R:wait(img.power.P, 30)
	click(Location(math.random(800, 900), math.random(450, 550)))
	if not Region(928, 321, 180, 150):existsClick('Go.png', 3) then
		return true
	end
	wait(10)
	paint('Travel: Exists')
	Region(OFFX+35, 850, 100, 100):highlight(2)
	Region(OFFX+35, 850, 100, 100):exists('Sleep.png', travSec)
	return false
end

function fightMulti(ship)
  local enemy = {
    { id = 'H', target = Pattern('Hull20.png'):color(), region = Region(OFFX-35, 1015, 205, 60), },
    { id = 'D', target = 'StatusDeath.png', region = Region(ship.offX+35, 850, 200, 100), },
	-- Add Survey
  }
	if cbHB then 
		table.insert(enemy, { id = 'HB', target = Pattern("HostileBattleship.png"):color(), region = Region(200, 200, 1350, 550)})
	end
	if cbHE then 
		table.insert(enemy, { id = 'HE', target = Pattern("HostileExplorer.png"):color(), region = Region(200, 200, 1350, 550)})
	end
	if cbHI then 
		table.insert(enemy, { id = 'HI', target = Pattern("HostileInterceptor.png"):color(), region = Region(200, 200, 1350, 550)})
	end
	if cbHS then 
		table.insert(enemy, { id = 'HS', target = Pattern("HostileSurvey.png"):color(), region = Region(200, 200, 1350, 550)})
	end
	
	
	local Exit = 0
	fightCnt = 0

	click(ship.center)
	if not (img.emptycargo.R:exists(img.emptycargo.P)) then
		click(ship.center)
		wait(0.5)
	end
	wait(.5)
	Region(180, 856, 90, 90):existsClick(Pattern("LocateA.png"))
	wait(.5)
	
	local tOff = -65
	if cbZoom then tOff = -100 end

	repeat
	paint('Fight: ' .. fightCnt)
		if cbDebug then Region(200, 200, 1350, 550):highlight(0.2) end
		local id, tar, m = regionWaitMulti(enemy, 1, cbDebug, nil, 1, false, true)
		if (id == -1) then
			--if ((fightCnt == 5) or (CleanTimer:check() > 10*60)) then
			if (fightCnt == 5) then
				cleanup()
				reset()
				wait(.5)
				fightCnt = 0
			else
				fightCnt = fightCnt + 1
			end
		elseif ((id == 1) or (id == 2)) then
			return true
		elseif (id ~= nil)  then
			click(m:offset(tOff, 0))
			TARGETS = TARGETS + 1
			attack(ship, tar)
		end
		setStopMessage("Runtime: " .. secondsToClock(StaTimer:check()) .. " Targets: " .. TARGETS .. " Attacks: " .. ATTACKS .. " Repairs: " .. REPAIRS .. " Mines: " .. MINE)
	until (exit == 1)
  return false
end

function attack(ship, tarType)
	if tarType == 'HB' then
		confirm = Pattern('ConfirmBattleship.png')
		paint('Attack: HB')
	elseif tarType == 'HE' then
		confirm = Pattern('ConfirmExplorer.png')
		paint('Attack: HE')
	elseif tarType == 'HI' then
		confirm = Pattern('ConfirmInterceptor.png')
		paint('Attack: HI')
	elseif tarType == 'HS' then
		confirm = Pattern('ConfirmSurvey.png')
		paint('Attack: HS')end
	
	if Region(979, 544, 124, 124):exists(confirm, 5) then
		if Region(1344, 668, 130, 130):existsClick('Attack.png', 3) then
			paint('Attack: Attack - '.. tarType)
			Region(OFFX+35, 850, 200, 100):exists('StatusTargeting.png', 3) --wait target
			Region(OFFX+35, 850, 200, 100):waitVanish('StatusTargeting.png', 30) --wait target
			ATTACKS = ATTACKS + 1
		end
	else
		return true
	end

	Region(ship.offX+35, 850, 200, 100):exists('StatusSleep.png', 10) --wait target
	wait(1)
	Region(ship.offX+35, 850, 200, 100):exists('StatusSleep.png', 5) --wait target
	wait(1.5)
	if (cbShields) and not Region(ship.offX+35, 850, 200, 100):exists('StatusDeath.png') then -- Wait for shields
		paint('Attack: Wait Shields')
		Region(ship.offX-35, 1020, 200, 30):exists(Pattern('Shields.png'):color(), 20)
	end
	return false
end

function FindShipOff(ship)
	if (img.emptycargo.R:exists(img.emptycargo.P)) then
		mat = img.docks.R:find(Pattern(ship))
			click(mat)
	end
	mat = img.docks.R:find(Pattern(ship))
	click(mat:getTarget())
	return mat:getX(), mat:getTarget()
end

function repairShip(ship)
	paint('Repair Ship')
	
	if not (img.emptycargo.R:exists(img.emptycargo.P)) then
		click(ship.center)
		wait(0.5)
	end
	if Region(ship.offX+35, 850, 200, 100):exists("StatusImpulse.png")or Region(ship.offX+35, 850, 200, 100):exists("StatusWarp.png") then
			return true
	else
		r, g, b = getColor(Region(250, 1000, 10, 10))
		if Region(ship.offX+35, 850, 160, 100):exists('StatusRepair.png') then
			paint('Repair: Repair')
			if Region(0, 850, 120, 120):existsClick(Pattern('RepairR.png'), 3) then
				REPAIRS = REPAIRS +1
			end
			wait(1)
			if cbHelp then
				Region(295, 965, 100, 100):existsClick(Pattern('RepairHelp.png'), 3)
			end
		elseif Region(ship.offX+35, 850, 200, 100):exists('StatusDeath.png') then
			if Region(0, 850, 120, 120):existsClick(Pattern('RepairR.png'), 3) then
				DEATHS = DEATHS + 1
			end
			wait(1)
			if cbHelp then
				Region(295, 965, 100, 100):existsClick(Pattern('RepairHelp.png'), 3)
			end
		elseif (g > r and g > b) then
			wait(.5)
			Region(284, 958, 130, 110):existsClick(Pattern("FreeArrow.png"))
			wait(.5)
			Region(180, 856, 90, 90):existsClick(Pattern("LocateA.png"))
			wait(.5)
			return false
		elseif (Region(ship.offX-40, 890, 200, 100):exists('Repairing.png')) then
			return true
		else
			return true
		end
		return true
	end
	return true
end

function recallShip(ship)
	paint('Recall Ship')
	print('Recall Ship')
	if cbDebug then img.emptycargo.R:highlight(.5) end
	if not (img.emptycargo.R:exists(img.emptycargo.P)) then
		click(ship.center)
		wait(0.5)
	end
	Region(166, 948, 124, 124):existsClick('RecallA.png')
	wait(.5)
	Region(ship.offX+35, 850, 200, 100):highlight(.5)
	if cbDebug then Region(ship.offX+35, 850, 200, 100):highlight(.5) end
	if Region(ship.offX+35, 850, 200, 100):exists("StatusImpulse.png") then -- wait exists impulse
		print('Recall Ship: Impulse')
		Region(ship.offX+35, 850, 200, 100):waitVanish("StatusImpulse.png", 5) -- wait vanish impulse
		return false
	elseif Region(ship.offX+35, 850, 200, 100):exists("StatusWarp.png", 10) then -- wait warping
		print('Recall Ship: Warp Vanish')
		Region(ship.offX+35, 850, 200, 100):waitVanish("StatusWarp.png", 5)
		return false
	else
		return true
	end
end

function hullCheck(ship)
	if img.emptycargo.R:exists(img.emptycargo.P) then
		reg = Region(ship.offX+45, 1050, 115, 5)
	else
		reg = Region(ship.offX-15, 1050, 115, 5)
	end
	Region(ship.offX+45, 1050, 115, 5):highlight(2)
	Region(ship.offX-15, 1050, 115, 5):highlight(2)

	local r, g, b = getColor(Location(reg:getX() + reg:getW() * .25 , reg:getY())) --for horizontal bar
    print("r = " .. r .. " | g = " .. g .. " | b = " .. b)

	if r >= 220 and g >= 220 and b >= 220 then
		return true
	else
		return false
	end
end

function DialogLogin()
	dialogInit()
	addTextView("Enter Password: ")
	addEditPassword('password', 'none')
	dialogShow("STFC - User Verification")
end

function findMine(img)
	paint('Find Mine')
	reg = Region(200, 200, 1350, 550)
	if cbDebug then reg:highlight(1) end

	test1 = listToTable(reg:findAllNoFindException(Pattern(img)))
	--print(img)
	for i, m in ipairs(test1) do
		if cbDebug then m:highlight(.5) end
		print(m:getScore())
		click(m)
		wait(3)
		--Region(1086, 181, 90, 90):highlight(.5)
		if Region(1086, 181, 90, 90):exists('MineStar.png') then
			--print('mine found')
			---Region(1368, 694, 290, 90):highlight(.5)
			if Region(1368, 694, 290, 90):existsClick('MineM.png', 5) then
				MINE = MINE + 1
				return true
			end
		end
	end
end

function mining(ship)
	paint('mining')
	Exit = 0
	click(ship.center)
	wait(.5)
	Region(180, 856, 90, 90):existsClick(Pattern("LocateA.png"))
	wait(.5)
	repeat
		paint('mining: Repeat')
		zoomout()
		if findMine('Mine3.png') then print('Mine 3 Found') Exit = 1 end
		if findMine('MineSmall.png') then  print('Small Mine Found') Exit = 1 end
		randomSwipe()
		wait(.5)
	until (Exit == 1)
	return false
end

function updateVer()
imgs = {}
table.insert(imgs, { pat = 'AdClose.png'})
table.insert(imgs, { pat = 'AllyHelp.png'})
table.insert(imgs, { pat = 'AtSymbol.png'})
table.insert(imgs, { pat = 'Attack.png'})
table.insert(imgs, { pat = 'ConfirmBattleship.png'})
table.insert(imgs, { pat = 'ConfirmExplorer.png'})
table.insert(imgs, { pat = 'ConfirmInterceptor.png'})
table.insert(imgs, { pat = 'ConfirmSurvey.png'})
table.insert(imgs, { pat = 'Bookmarks.png'})
table.insert(imgs, { pat = 'CargoClose.png'})
table.insert(imgs, { pat = 'Claim.png'})
table.insert(imgs, { pat = 'ClaimA.png'})
table.insert(imgs, { pat = 'Collapse.png'})
table.insert(imgs, { pat = 'ConfirmR.png'})
table.insert(imgs, { pat = 'Corvette.png'})
table.insert(imgs, { pat = 'EmptyCargo.png'})
table.insert(imgs, { pat = 'Fortunate.png'})
table.insert(imgs, { pat = 'FreeArrow.png'})
table.insert(imgs, { pat = 'FreeColor.png'})
table.insert(imgs, { pat = 'GiftsBack.png'})
table.insert(imgs, { pat = 'Go.png'})
table.insert(imgs, { pat = 'HelpAll.png'})
table.insert(imgs, { pat = 'HostileBattleship.png'})
table.insert(imgs, { pat = 'HostileExplorer.png'})
table.insert(imgs, { pat = 'HostileInterceptor.png'})
table.insert(imgs, { pat = 'HostileSurvey.png'})
table.insert(imgs, { pat = 'Hull20.png'})
table.insert(imgs, { pat = 'LocateA.png'})
table.insert(imgs, { pat = 'MapPin.png'})
table.insert(imgs, { pat = 'MineLarge.png'})
table.insert(imgs, { pat = 'MineSmall.png'})
table.insert(imgs, { pat = 'Mine3.png'})
table.insert(imgs, { pat = 'Phindra.png'})
table.insert(imgs, { pat = 'Power.png'})
table.insert(imgs, { pat = 'Realta.png'})
table.insert(imgs, { pat = 'RecallA.png'})
table.insert(imgs, { pat = 'Relaunch.png'})
table.insert(imgs, { pat = 'RepairColor.png'})
table.insert(imgs, { pat = 'RepairFree.png'})
table.insert(imgs, { pat = 'RepairHelp.png'})
table.insert(imgs, { pat = 'RepairR.png'})
table.insert(imgs, { pat = 'Repairing.png'})
table.insert(imgs, { pat = 'Shields.png'})
table.insert(imgs, { pat = 'StatusDeath.png'})
table.insert(imgs, { pat = 'StatusImpulse.png'})
table.insert(imgs, { pat = 'StatusRepair.png'})
table.insert(imgs, { pat = 'StatusSleep.png'})
table.insert(imgs, { pat = 'StatusTargeting.png'})
table.insert(imgs, { pat = 'StatusWarp.png'})
table.insert(imgs, { pat = 'System.png'})
table.insert(imgs, { pat = 'Talla.png'})
table.insert(imgs, { pat = 'Turas.png'})
	
-- Setup Github and check for updates
	gitVersion = loadstring(httpGet("https://raw.githubusercontent.com/Zenkrye/STFC/main/STFCver.lua"))
	webVersion = gitVersion()
	curVersion = dofile(ROOT .."STFCver.lua")
	print('New Version: ' .. webVersion .. '  Current Version: ' .. curVersion)
	if curVersion == webVersion then
    	toast ("You are running the most current version!")
	else
 	   httpDownload("https://raw.github.com/Zenkrye/STFC/main/STFCver.lua", ROOT .."STFCver.lua")
		httpDownload("https://raw.github.com/Zenkrye/STFC/main/STFC.luae3", ROOT .."STFC.luae3")
		for i = 1, table.getn(imgs) do
			toast ("Updating files " .. i .. " of " .. table.getn(imgs))
			gitImg = "https://raw.github.com/Zenkrye/STFC/main/Images/" .. imgs[i].pat
			--print(gitImg .. " Dir: " .. DIR_IMAGES .. " Img: " .. imgs[i].pat)
			--print(gitImg .. DIR_IMAGES .. imgs[i].pat)
			httpDownload(gitImg , DIR_IMAGES .. "/" .. imgs[i].pat)
			total = i
		end 	 
		scriptExit("Star Trek Fleet Command has been updated! " .. total .. " images updated")
	end
end

--- Main ---
updateVer()

--Only initialize t / timer ONCE during script!
StaTimer = Timer()
-- Base Mine Timer off Check Timer, Store mine time > check timer
MineTimer = Timer()
MineTimer2 = Timer()
CheckTimer = Timer()
ships = {}

DialogLogin()

if password == 'testing1' then
	DialogFull()
else
	DialogTrial()
end

paint('initilize')
shipImg = {"NONE", 'Realta.png', 'Corvette.png', 'Fortunate.png', 'phindra.png', 'Turas.png', 'Talla.png'}
if (spShipA ~= 1) then
	paint('Ship 1)
	OFFX, CENTER = FindShipOff(shipImg[spShipA])
	if OFFX > 0 then
		table.insert(ships, { target = shipImg[spShipA], action = spActionA, offX = OFFX, center = CENTER, mine = true, fight = false, repair = false, recall = false})
	end
end
wait(.5)
if (spShipB ~= 1) then
	paint('Ship 2)
	OFFX, CENTER = FindShipOff(shipImg[spShipB])
	if OFFX > 0 then
		table.insert(ships, { target = shipImg[spShipB],  action = spActionB, offX = OFFX, center = CENTER, mine = false, fight = true, repair = false, recall = false})
	end
end
wait(.5)
if (spShipC ~= 1) then
	paint('Ship 3)
	OFFX, CENTER = FindShipOff(shipImg[spShipC])
	if OFFX > 0 then
		table.insert(ships, { target = shipImg[spShipC],  action = spActionC, offX = OFFX, center = CENTER, mine = false, fight = true, repair = false, recall = false})
	end
end

print ('Table: ' .. table.getn(ships))
		
if cbClaim then claim() end
if cbHelp then helpally() end
CheckTimer:set()

while (true)
do
	for i = 1, table.getn(ships) do
		local s = ships[i]
		--print("Ships: " .. i .. " " .. s.target .. " " .. s.action .. " " .. s.offX )

		
		--Check Ship Status for Death, repair or Sleep
		if Region(s.offX+35, 850, 200, 100):exists('StatusRepair.png') then
			s.repair = true
		elseif Region(s.offX+35, 850, 200, 100):exists('StatusDeath.png') then
			s.repair = true
			s.recall = false
		elseif Region(s.offX+35, 850, 200, 100):exists('StatusSleep.png') and s.action == 2 then
			s.recall = true
		end

		if (s.repair) then
			s.repair = repairShip(s)
		end
		if (s.action == 2) then
			if ((not s.mine) and (MineTimer:check() > 15*60)) then
				s.recall = true
				s.mine = true
			elseif (s.mine) then
				s.mine = mining(s)
				MineTimer:set()
			end
		end
		if (s.action == 1 and not s.repair) then 
			reset()
			s.recall = fightMulti(s)
			s.repair = s.recall
		end
		if (s.recall) then 
			s.recall = recallShip(s)
		end
		paint('End Inner Loop')
	end
	if (CheckTimer:check() > 10*60) then
			print(' Check Timer ' )
			if cbClaim then claim() end
			if cbHelp then helpally() end
			--cleanup()
			CheckTimer:set()
	end
	--paint('End Main Loop: ' .. CheckTimer:check())
	wait(3)
end