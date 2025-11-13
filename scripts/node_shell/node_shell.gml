function Node_Shell(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Execute Shell";
	always_pad = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Path("Path"));
	
	newInput(1, nodeValue_Text("Script"));
	
	setTrigger(1, "Run", [ THEME.sequence_control, 1, COLORS._main_value_positive ]);
	
	trusted = PROGRAM_ARGUMENTS._trusted;
	
	static onValueUpdate = function() { trusted = false; }
	
	setTrigger(1,,, function() /*=>*/ {return update()});
	
	static update = function() { 
		if(project.online) return false;
		
		var _pro = getInputData(0);
		var _scr = getInputData(1);
		if(_pro == "" && _scr == "") return;
		
		if(trusted) {
			shell_execute_async(_pro, _scr);
		} else {
			var dia = dialogCall(o_dialog_run_shell);
			dia.setData(self, _pro, _scr);
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var txt  = getInputData(0);
		
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, txt);
	}
}