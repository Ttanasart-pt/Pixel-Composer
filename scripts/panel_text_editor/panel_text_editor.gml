function Panel_Text_Editor(_textArea, _inputFunc, _context) : PanelContent() constructor {
	title = "";
	w = ui(640);
	h = ui(480);
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
		if(buttonInstant(THEME.button_hide, bx, by, bs, bs, [ mx, my ], pFOCUS, pHOVER, txt, THEME.new_line_shift, shift_new_line) == 2)
			shift_new_line = !shift_new_line;
		bx += bs + ui(4);
		
		var bx = w - ui(8) - bs;
		if(buttonInstant(THEME.button_hide, bx, by, bs, bs, [ mx, my ], pFOCUS, pHOVER, "Apply", THEME.accept,, COLORS._main_value_positive) == 2) 
			_textArea.apply();
		bx -= bs + ui(4);
		
		var tx = ui(8);
		var ty = ui(4 + 36);
		var tw = w - ui(8 + 8);
		var th = h - ui(4 + 36 + 8);
		
		var _text = inputFunc();
		_textArea.register();
		_textArea.setFocusHover(pFOCUS, pHOVER);
		_textArea.shift_new_line = shift_new_line;
		_textArea.drawParam(new widgetParam(tx, ty, tw, th, _text,, [mx, my], x, y));
	}
	
	function onClose() {
		_textArea.apply();
		context.popup_dialog = noone;
	}
}