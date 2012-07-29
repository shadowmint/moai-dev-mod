----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

MOAISim.openWindow ( "test", 320, 480 )

viewport = MOAIViewport.new ()
viewport:setSize ( 320, 480 )
viewport:setScale ( 320, 480 )

layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )

charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'

font1 = MOAIFont.new ()
font1:load ( 'arial-rounded.TTF' )
font1:preloadGlyphs ( charcodes, 24 )

continue = false

function setStyleTests ()
	while 1 do
		text = '.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\
		enim vitae porttitor semper,\
		nisi est vestibulum elit, non varius tortor dui at quam.'
		
		local textbox = MOAITextBox.new ()
		textbox:setString ( text )
		textbox:setRect ( -150, -230, 150, 230 )
		textbox:setYFlip ( true )
		layer:insertProp ( textbox )
	
		local style = MOAITextStyle.new ()
		style:setColor ( 1, 1, 1, 1 )
		style:setFont ( font1 )
		style:setSize ( 24 )
		textbox:setStyle ( style )
		
		continue = false
		repeat coroutine.yield () until continue
		
		textbox:nextPage ()
		
		continue = false
		repeat coroutine.yield () until continue
		textbox:setReveal ( 0 )
	end
end

-- tests
function onKeyboardEvent ( key, down )
	if down then
		if key == 32 then -- continue
			continue = true
		else
			return
		end
	end
end

MOAIInputMgr.device.keyboard:setCallback ( onKeyboardEvent )
thread = MOAIThread.new ()
thread:run ( setStyleTests )
