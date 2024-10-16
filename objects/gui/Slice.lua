local base = (...):gsub('[^%.]+$', '')
local Node = require(base .. 'Node')

local SliceNode = Node:extend()
SliceNode.className = 'SliceNode'

function SliceNode.draw(self)
	love.graphics.setBlendMode(self.blendMode)
	love.graphics.setColor(self.color)

	local lt, top = 0, 0
	local rt, bot = self.w, self.h
	local m = self.margins
	local s = self.lastAlloc.scale
	-- Draw corners
	love.graphics.draw(self.image, self.quadTl, -lt, -top, 0, s, s) -- Top Left
	love.graphics.draw(self.image, self.quadTr, rt-m.rt, -top, 0, s, s) -- Top Right
	love.graphics.draw(self.image, self.quadBl, -lt, bot-m.bot, 0, s, s) -- Bottom Left
	love.graphics.draw(self.image, self.quadBr, rt-m.rt, bot-m.bot, 0, s, s) -- Bottom Right
	-- Draw sides
	love.graphics.draw(self.image, self.quadTop, -lt+m.lt, -top, 0, self.sliceSX, s) -- Top
	love.graphics.draw(self.image, self.quadBot, -lt+m.lt, bot-m.bot, 0, self.sliceSX, s) -- Bottom
	love.graphics.draw(self.image, self.quadLt, -lt, -top+m.top, 0, s, self.sliceSY) -- Left
	love.graphics.draw(self.image, self.quadRt, rt-m.rt, -top+m.top, 0, s, self.sliceSY) -- Right
	-- Draw center
	love.graphics.draw(self.image, self.quadC, -lt+m.lt, -top+m.top, 0, self.sliceSX, self.sliceSY) -- Center
end

function SliceNode.drawDebug(self)
	SliceNode.super.drawDebug(self)
	local lt, top = 0, 0
	local rt, bot = self.w, self.h
	local m = self.margins
	love.graphics.line(lt+m.lt, top, lt+m.lt, bot)
	love.graphics.line(rt-m.rt, top, rt-m.rt, bot)
	love.graphics.line(lt, top+m.top, rt, top+m.top)
	love.graphics.line(lt, bot-m.bot, rt, bot-m.bot)
end

function SliceNode.updateScale(self, x, y, w, h, scale)
	local isDirty = SliceNode.super.updateScale(self, x, y, w, h, scale)
	if isDirty then
		for k,designSize in pairs(self.designMargins) do
			self.margins[k] = designSize * scale
		end
		return true
	end
end

function SliceNode.updateContentSize(self, x, y, w, h, scale)
	local isDirty = SliceNode.super.updateContentSize(self, x, y, w, h, scale)
	local m = self.margins
	local innerSliceW = self.w - m.lt - m.rt
	local innerSliceH = self.h - m.top - m.bot
	self.sliceSX = innerSliceW/self.innerQuadW
	self.sliceSY = innerSliceH/self.innerQuadH
	return isDirty
end

function SliceNode.set(self, image, quad, margins, w, modeX, h, modeY, pivot, anchor, padX, padY)
	w, h = w or 100, h or 100
	local mCount = #margins
	local m
	if mCount == 1 then -- One value, all are equal.
		m = { lt=margins[1], rt=margins[1], top=margins[1], bot=margins[1] }
	elseif mCount == 2 then -- Two values, both sides equal along either axis.
		m = { lt=margins[1], rt = margins[1], top=margins[2], bot=margins[2] }
	else -- Four values, all are different.
		m = { lt=margins[1], rt=margins[2], top=margins[3], bot=margins[4] }
	end
	self.margins = m
	self.designMargins = { lt=m.lt, rt=m.rt, top=m.top, bot=m.bot }
	padX = padX or (m.lt + m.rt)/2 -- Use slice margins for default padding.
	padY = padY or padX or (m.top + m.bot)/2
	SliceNode.super.set(self, w, modeX, h, modeY, pivot, anchor, padX, padY)
	-- super.set sets self.innerW/H, designInnerW/H.
	self.blendMode = 'alpha'
	self.color = {1, 1, 1, 1}

	local imgType = type(image)
	if imgType == 'string' then
		image = new.image(image)
	elseif not (imgType == 'userdata' and image.type and image:type() == 'Image') then
		error('SpriteNode() - "image" must be either a string filepath to an image or a Love Image object, you gave: "' .. tostring(image) .. '" instead.')
	end
	self.image = image
	local lt, top, qw, qh = 0, 0, 0, 0
	local imgW, imgH

	local quadType = type(quad)
	if quadType == 'userdata' and quad.typeOf and quad:typeOf('Quad') then
		lt, top, qw, qh = quad:getViewport()
	elseif quadType == 'table' then
		lt, top, qw, qh = unpack(quad)
		imgW, imgH = self.image:getDimensions()
	else
		qw, qh = self.image:getDimensions()
		imgW, imgH = qw, qh
	end

	local rt, bot = lt + qw, top + qh
	local innerLt, innerRt = lt + m.lt, rt - m.rt
	local innerTop, innerBot = top + m.top, bot - m.bot
	local innerW, innerH = qw - m.lt - m.rt, qh - m.top - m.bot
	self.innerQuadW, self.innerQuadH = innerW, innerH
	self.sliceSX = (w - m.lt - m.rt)/self.innerQuadW
	self.sliceSY = (h - m.top - m.bot)/self.innerQuadH

	-- Make 4 corner quads.
	self.quadTl = new.quad(lt, top, m.lt, m.top, imgW, imgH)
	self.quadTr = new.quad(innerRt, top, m.rt, m.top, imgW, imgH)
	self.quadBl = new.quad(lt, innerBot, m.lt, m.bot, imgW, imgH)
	self.quadBr = new.quad(innerRt, innerBot, m.rt, m.bot, imgW, imgH)
	-- Make 4 edge quads.
	self.quadTop = new.quad(innerLt, top, innerW, m.top, imgW, imgH)
	self.quadBot = new.quad(innerLt, innerBot, innerW, m.bot, imgW, imgH)
	self.quadLt = new.quad(lt, innerTop, m.lt, innerH, imgW, imgH)
	self.quadRt = new.quad(innerRt, innerTop, m.rt, innerH, imgW, imgH)
	-- Make center quad.
	self.quadC = new.quad(innerLt, innerTop, innerW, innerH, imgW, imgH)
end

return SliceNode
