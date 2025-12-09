function Node_Audio_Loudness(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Audio Loudness";
	setDimension(96, 72);
	setDrawIcon(s_node_audio_loudness);
	
	newInput(0, nodeValue_Float("Audio Data", []))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Loudness", VALUE_TYPE.float, 0));
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dat = _data[0];
		
		var N    = array_length(_dat);
		var val  = 0;
		if(N == 0) return 0;
		
		for( var i = 0; i < N; i++ )
			val += _dat[i] * _dat[i];
		val = sqrt(val / N);
		
		var dec = 10 * log10(val);
		return dec;
	}
}