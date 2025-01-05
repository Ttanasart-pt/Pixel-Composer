function Panel_Text_Editor(_textArea, _inputFunc, _context) : PanelContent() constructor {
	title = "";
	w     = min(WIN_W - ui(64), ui(800));
	h     = ui(480);
	auto_pin = true;
	
	self._textArea = new textArea(_textArea.input, _textArea.onModify);
	self._textArea.color  = _textArea.color;
	self._textArea.font   = _textArea.font;
	self._textArea.format = _textArea.format;
	
	self._textArea.parser_server		  = _textArea.parser_server;
	self._textArea.autocomplete_server	  = _textArea.autocomplete_server;
	self._textArea.autocomplete_object	  = _textArea.autocomplete_object;
	self._textArea.function_guide_server  = _textArea.function_guide_server;
	
	self.inputFunc = method(self, _inputFunc);
	self.context   = _context;
	
	shift_new_line = false;
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var bx = ui(8);
		var by = ui(4);
		var bs = ui(32);
		
		var txt = shift_new_line? "New line with Shift + Enter" : "New line with Enter";
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, txt, THEME.new_line_shift, shift_new_line) == 2)
			shift_new_line = !shift_new_line;
		bx += bs + ui(4);
		
		var txt = _textArea.show_line_number? "Hide line number" : "Show line number";
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, txt, THEME.code_show_line, _textArea.show_line_number) == 2)
			_textArea.show_line_number = !_textArea.show_line_number;
		bx += bs + ui(4);
		
		var txt = _textArea.use_autocomplete? "Disable Autocomplete" : "Enable Autocomplete";
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, txt, THEME.code_show_auto, _textArea.use_autocomplete) == 2)
			_textArea.use_autocomplete = !_textArea.use_autocomplete;
		bx += bs + ui(4);
		
		var txt = "Syntax Highlight";
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, txt, THEME.code_syntax_highlight, _textArea.syntax_highlight) == 2)
			_textArea.syntax_highlight = !_textArea.syntax_highlight;
		bx += bs + ui(4);
		
		var bx = w - ui(8) - bs;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, "Apply", THEME.accept,, COLORS._main_value_positive) == 2) 
			_textArea.apply();
		bx -= bs + ui(4);
		
		var pd = ui(8 - in_dialog * 6);
		var tx = pd;
		var ty = ui(4 + 36);
		var tw = w - pd * 2;
		var th = h - pd - ty;
		
		var _text    = inputFunc();
		var _prevBox = _textArea.boxColor;
		
		_textArea.setMaxHieght(th);
		_textArea.register();
		_textArea.setFocusHover(pFOCUS, pHOVER);
		_textArea.shift_new_line = shift_new_line;
		_textArea.boxColor = merge_color(CDEF.main_white, CDEF.main_ltgrey, .5);
		
		_textArea.drawParam(new widgetParam(tx, ty, tw, th, _text, {}, [ mx, my ], x, y));
		
		_textArea.boxColor = _prevBox;
	}
	
	static checkClosable = function() {
		return o_dialog_textbox_autocomplete.textbox != _textArea;
	}
	
	static onClose = function() {
		_textArea.apply();
		context.popup_dialog = noone;
	}
}