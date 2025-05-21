function Node_Animation_Control(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Animation Control";
	setDimension(96, 96);
	
	newInput(0, nodeValue_Trigger("Toggle Play / Pause" ));
	
	newInput(1, nodeValue_Trigger("Pause" ));
	
	newInput(2, nodeValue_Trigger("Resume" ));
	
	newInput(3, nodeValue_Trigger("Play From Beginning" ));
	
	newInput(4, nodeValue_Trigger("Play once" ));
	
	newInput(5, nodeValue_Trigger("Skip Frames" ));
	
	newInput(6, nodeValue_Int("Skip Frames Count", 1));
	
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