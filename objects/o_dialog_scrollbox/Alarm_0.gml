/// @description init
#region pos
	var hght = line_height(f_p0, 8);
	var hh = 0;
	
	for( var i = 0; i < array_length(scrollbox.data); i++ ) {
		if(scrollbox.data[i] == -1) {
			hh += ui(8);
			continue;
		}
		
		hh += hght;
	}
	
	dialog_h = min(max_h, hh);
	sc_content.resize(dialog_w, dialog_h);
#endregion
event_inherited();