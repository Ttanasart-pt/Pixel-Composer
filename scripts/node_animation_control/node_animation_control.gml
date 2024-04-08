function Node_Animation_Control(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Animation Control";
	setDimension(96, 96);
	
	inputs[| 0] = nodeValue("Toggle Play / Pause", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false );
	
	inputs[| 1] = nodeValue("Pause", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false );
	
	inputs[| 2] = nodeValue("Resume", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false );
	
	inputs[| 3] = nodeValue("Play From Beginning", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false );
	
	inputs[| 4] = nodeValue("Play once", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false );
	
	inputs[| 5] = nodeValue("Skip Frames", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false );
	
	inputs[| 6] = nodeValue("Skip Frames Count", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	static step = function() { 
		if(getInputData(0))
			PROJECT.animator.toggle();
		
		if(getInputData(1))
			PROJECT.animator.pause();
		
		if(getInputData(2))
			PROJECT.animator.resume();
		
		if(getInputData(3)) {
			PROJECT.animator.stop();
			PROJECT.animator.play();
		} 
		
		if(getInputData(4))
			PROJECT.animator.render();
		
		if(getInputData(5)) { 
			var fr = getInputData(6);
			PROJECT.animator.setFrame(CURRENT_FRAME + fr);
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var ind  = 0;
		
		if(PROJECT.animator.is_playing) ind = 1;
		
		draw_sprite_fit(THEME.sequence_control, ind, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}