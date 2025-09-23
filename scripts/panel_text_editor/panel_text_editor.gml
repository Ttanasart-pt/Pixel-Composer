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
	
	inputFunc = method(self, _inputFunc);
	context   = _context;
	
	shift_new_line  = false;
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var bx = ui(8);
		var by = in_dialog? ui(4) : ui(8);
		var bs = ui(28);
		var bp = THEME.button_hide_fill;
		var cc = COLORS._main_icon_light;
		var m  = [mx,my];
		
		var txt = shift_new_line? "New line with Shift + Enter" : "New line with Enter";
		if(buttonInstant_Pad(bp, bx, by, bs, bs, m, pHOVER, pFOCUS, txt, THEME.new_line_shift, shift_new_line, cc, 1, ui(8)) == 2)
			shift_new_line = !shift_new_line;
		bx += bs + ui(4);
		
		var txt = editor.show_line_number? "Hide line number" : "Show line number";
		if(buttonInstant_Pad(bp, bx, by, bs, bs, m, pHOVER, pFOCUS, txt, THEME.code_show_line, editor.show_line_number, cc, 1, ui(8)) == 2)
			editor.show_line_number = !editor.show_line_number;
		bx += bs + ui(4);
		
		var txt = editor.use_autocomplete? "Disable Autocomplete" : "Enable Autocomplete";
		if(buttonInstant_Pad(bp, bx, by, bs, bs, m, pHOVER, pFOCUS, txt, THEME.code_show_auto, editor.use_autocomplete, cc, 1, ui(8)) == 2)
			editor.use_autocomplete = !editor.use_autocomplete;
		bx += bs + ui(4);
		
		var txt = "Syntax Highlight";
		if(buttonInstant_Pad(bp, bx, by, bs, bs, m, pHOVER, pFOCUS, txt, THEME.code_syntax_highlight, editor.syntax_highlight, cc, 1, ui(8)) == 2)
			editor.syntax_highlight = !editor.syntax_highlight;
		bx += bs + ui(4);
		
		var bx = w - ui(8) - bs;
		var txt = "Apply";
		if(buttonInstant_Pad(bp, bx, by, bs, bs, m, pHOVER, pFOCUS, txt, THEME.accept_16, 0, COLORS._main_value_positive, 1, ui(8)) == 2) 
			editor.apply();
		bx -= bs + ui(4);
		
		var pd = in_dialog? ui(8) : ui(4);
		var tx = pd;
		var ty = by + bs + ui(4);
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