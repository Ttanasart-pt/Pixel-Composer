/// @description
#region data
	depth = -9999;
	
	dialog_x = 0;
	dialog_y = 0;
	dialog_w = 280;
	dialog_h = 32;
	
	textbox	  = noone;
	prompt	  = "";
	index     = 0;
	
	function activate(textbox) { 
		INLINE
		self.textbox   = textbox;
	}
	
	function deactivate(textbox) {
		INLINE
		if(textbox != self.textbox) return;
		
		self.textbox   = noone;
	}
#endregion

