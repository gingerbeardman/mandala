-- https://twitter.com/aemkei/status/1378106731386040322?s=46&t=vAQ328oQf-s81-tV9T-wKQ

import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

gfx.setBackgroundColor(gfx.kColorBlack)
playdate.display.setRefreshRate(10)

local playerSprite = nil
local W = playdate.display.getWidth()
local H = playdate.display.getHeight()

fnt = gfx.font.new("fonts/Roobert-11-Medium")

local imgSprite = gfx.image.new(W,H)
local imgHud = gfx.image.new(W//3,H//8)

spr = gfx.sprite.new( imgSprite )
spr:moveTo( 0,0 )
spr:setCenter( 0,0 )
spr:add()

hud = gfx.sprite.new( imgHud )
hud:moveTo( 15,190 )
hud:setCenter( 0,0 )
hud:add()

function p_xor_mod(x,y,z) return (x ~ y) % z end
function p_or_mod(x,y,z) return (x | y) % z end
function p_mul_and(x,y,z) return (x * y) & z end
function p_xor_lsh(x,y,z) return (x ~ y) << z end
function p_mul_mod(x,y,z) return (x * z) % (y+1) end
-- function p_mul_mod_offset(x,y,z) return ((x-W//2) * z) % ((y-H//2)+1) end

local allFuncs = {p_xor_mod, p_or_mod, p_mul_and, p_xor_lsh, p_mul_mod} --p_mul_mod_offset
local allLabels = {"(x ~ y) %% %s", "(x | y) %% %s", "(x * y) & %s", "(x ~ y) << %s", "(x * %s) %% y", "((x-200) * %s) %% (y-120)"}

local current = 1
local f = allFuncs[current]
local ft = allLabels[current]
local delta = 1
local var = 5
local changed = true

function drawPixels()
	gfx.lockFocus(imgSprite)
	for x=0,W do
		for y=0,H do
			p = f(x,y, var)
			if p == 0 then
				gfx.setColor(gfx.kColorWhite)
			else
				gfx.setColor(gfx.kColorBlack)
			end
			gfx.drawPixel(x,y)
		end
	end
	gfx.unlockFocus()

	changed = false
end

function drawHud()
	gfx.lockFocus(imgHud)
	gfx.clear(gfx.kColorWhite)
	fnt:drawText(string.format(ft,var), 5,5)
	gfx.unlockFocus()

	changed = false
end

function math.ring(a, min, max)
	if min > max then
		min, max = max, min
	end
	return min + (a-min)%(max-min)
end

function math.ring_int(a, min, max)
	return math.ring(a, min, max+1)
end

function setVar(m)
	var = m
	changed = true
end

function funcNext()
	current = math.ring_int(current+1,1,#allFuncs)
	ft = allLabels[current]
	
	changed = true

	return allFuncs[current]
end

function funcPrev()
	current = math.ring_int(current-1,1,#allFuncs)
	ft = allLabels[current]
	
	changed = true

	return allFuncs[current]
end

local myInputHandlers = {

	AButtonDown = function()
		delta = 5
	end,
	AButtonUp = function()
		delta = 1
	end,
	BButtonDown = function()
		delta = 10
	end,
	BButtonUp = function()
		delta = 1
	end,
	upButtonDown = function()
		setVar(var + delta)
	end,
	downButtonDown = function()
		setVar(var - delta)
	end,
	leftButtonDown = function()
		f = funcPrev()
	end,
	rightButtonDown = function()
		f = funcNext()
	end,

	cranked = function(change, acceleratedChange)
	end,
}
playdate.inputHandlers.push(myInputHandlers)

function playdate.update()
	if changed == true then
		drawPixels()
		drawHud()
	end

	gfx.sprite.update()
end
