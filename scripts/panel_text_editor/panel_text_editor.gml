function Panel_Text_Editor(_textArea, _inputFunc, _context) : PanelContent() constructor {
	title = "";
	w     = min(WIN_W - ui(64), ui(800));
	h     = ui(480);
	auto_pin = true;
	
	editor = new textArea(_textArea.input, _textArea.onModify);
	editor.color  = _textArea.color;
	editor.font   = _textArea.font;
	editor.format = _textArea.format;
	editor.border_heightlight_color = COLORS._main_icon;
	
	editor.parser_server		  = _textArea.parser_server;
	editor.autocomplete_server	  = _textArea.autocomplete_server;
	editor.autocomplete_object	  = _textArea.autocomplete_object;
	editor.function_guide_server  = _textArea.function_guide_server;
	editor.select_on_click        = false;
	
	self.inputFunc = method(self, _inputFunc);
	self.context   = _context;
	
	shift_new_line  = false;
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var bx = ui(8);
		var by = ui(4);
		var bs = ui(32);
		
		var txt = shift_new_line? "New line with Shift + Enter" : "New line with Enter";
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, txt, THEME.new_line_shift, shift_new_line) == 2)
			shift_new_line = !shift_new_line;
		bx += bs + ui(4);
		
		var txt = editor.show_line_number? "Hide line number" : "Show line number";
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, txt, THEME.code_show_line, editor.show_line_number) == 2)
			editor.show_line_number = !editor.show_line_number;
		bx += bs + ui(4);
		
		var txt = editor.use_autocomplete? "Disable Autocomplete" : "Enable Autocomplete";
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, txt, THEME.code_show_auto, editor.use_autocomplete) == 2)
			editor.use_autocomplete = !editor.use_autocomplete;
		bx += bs + ui(4);
		
		var txt = "Syntax Highlight";
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, txt, THEME.code_syntax_highlight, editor.syntax_highlight) == 2)
			editor.syntax_highlight = !editor.syntax_highlight;
		bx += bs + ui(4);
		
		var bx = w - ui(8) - bs;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, "Apply", THEME.accept,, COLORS._main_value_positive) == 2) 
			editor.apply();
		bx -= bs + ui(4);
		
		var pd = ui(8 - in_dialog * 6);
		var tx = pd;
		var ty = ui(4 + 36);
		var tw = w - pd * 2;
		var th = h - pd - ty;
		
		var _text    = inputFunc();
		var _prevBox = editor.boxColor;
		
		editor.setMaxHeight(th);
		editor.register();
		editor.setFocusHover(pFOCUS, pHOVER);
		editor.shift_new_line = shift_new_line;
		editor.boxColor = merge_color(CDEF.main_white, CDEF.main_ltgrey, .5);
		
		editor.drawParam(new widgetParam(tx, ty, tw, th, _text, {}, [ mx, my ], x, y));
		
		editor.boxColor = _prevBox;
	}
	
	static checkClosable = function() { return o_dialog_textbox_autocomplete.textbox != editor; }
	
	static onClose = function() {
		editor.apply();
		context.popup_dialog = noone;
	}
}