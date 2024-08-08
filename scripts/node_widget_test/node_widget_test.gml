function Node_Widget_Test(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Widget Test";
	setDimension(96, 32 + 24 * 1);
	draw_padding = 8;
	
	inputs[ 0] = nodeValue("textBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)                                      .setDisplay(VALUE_DISPLAY._default)
	inputs[ 1] = nodeValue("rangeBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 0])                                .setDisplay(VALUE_DISPLAY.range)
	inputs[ 2] = nodeValue("vectorBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 0])                               .setDisplay(VALUE_DISPLAY.vector)
	inputs[ 3] = nodeValue("vectorRangeBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 0, 0, 0])                    .setDisplay(VALUE_DISPLAY.vector_range)
	inputs[ 4] = nodeValue("rotator", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)                                      .setDisplay(VALUE_DISPLAY.rotation)
	inputs[ 5] = nodeValue("rotatorRange", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 0])                            .setDisplay(VALUE_DISPLAY.rotation_range)
	inputs[ 6] = nodeValue_Float("rotatorRandom", self, [0, 0, 0, 0, 0])                  .setDisplay(VALUE_DISPLAY.rotation_random)
	inputs[ 7] = nodeValue("slider", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)                                       .setDisplay(VALUE_DISPLAY.slider)
	inputs[ 8] = nodeValue("sliderRange", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])                           .setDisplay(VALUE_DISPLAY.slider_range)
	inputs[ 9] = nodeValue("areaBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_AREA)						        .setDisplay(VALUE_DISPLAY.area)
	inputs[10] = nodeValue("paddingBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])                      .setDisplay(VALUE_DISPLAY.padding)
	inputs[11] = nodeValue("cornerBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])                       .setDisplay(VALUE_DISPLAY.corner)
	inputs[12] = nodeValue("controlPointBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0, 0, 0, 0 ])        .setDisplay(VALUE_DISPLAY.puppet_control)
	inputs[13] = nodeValue("scrollBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)                                    .setDisplay(VALUE_DISPLAY.enum_scroll, [ "Choice 1", "Choice 2" ])
	inputs[14] = nodeValue("buttonGroup", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)                                  .setDisplay(VALUE_DISPLAY.enum_button, [ "Choice 1", "Choice 2" ])
	inputs[15] = nodeValue("matrixGrid", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, array_create(9))                     .setDisplay(VALUE_DISPLAY.matrix, { size: 3 })
	inputs[16] = nodeValue("transformBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0, 0 ])                 .setDisplay(VALUE_DISPLAY.transform)
	inputs[17] = nodeValue("transformBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0, 0 ])                 .setDisplay(VALUE_DISPLAY.transform)
	inputs[18] = nodeValue("quarternionBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])                  .setDisplay(VALUE_DISPLAY.d3quarternion)

	inputs[19] = nodeValue_Bool("checkBox", self, false)                               .setDisplay(VALUE_DISPLAY._default)

	inputs[20] = nodeValue_Color("buttonColor", self, 0)                                  .setDisplay(VALUE_DISPLAY._default)
	inputs[21] = nodeValue_Palette("buttonPalette", self, array_clone(DEF_PALETTE))                     .setDisplay(VALUE_DISPLAY.palette)
	inputs[22] = nodeValue_Gradient("buttonGradient", self, new gradientObject(cola(c_white)))  .setDisplay(VALUE_DISPLAY._default)

	inputs[23] = nodeValue("pathArrayBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, [])                                 .setDisplay(VALUE_DISPLAY.path_array, { filter: [ "image|*.png;*.jpg", "" ] })
	inputs[24] = nodeValue("pathLoad", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")                                      .setDisplay(VALUE_DISPLAY.path_load)
	inputs[25] = nodeValue("pathSave", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")                                      .setDisplay(VALUE_DISPLAY.path_save)
	inputs[26] = nodeValue("fontScrollBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")                                .setDisplay(VALUE_DISPLAY.path_font)

	inputs[27] = nodeValue("curveBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11)                          .setDisplay(VALUE_DISPLAY._default)

	inputs[28] = nodeValue_Text("textArea", self, "")                                     .setDisplay(VALUE_DISPLAY._default)
	inputs[29] = nodeValue_Text("textBox", self, "")                                      .setDisplay(VALUE_DISPLAY.text_box)
	inputs[30] = nodeValue_Text("textArea", self, "")                                     .setDisplay(VALUE_DISPLAY.codeLUA)
	inputs[31] = nodeValue_Text("textArea", self, "")                                     .setDisplay(VALUE_DISPLAY.codeHLSL)
	inputs[32] = nodeValue_Text("textArrayBox", self, [])                                 .setDisplay(VALUE_DISPLAY.text_array, { data: [ "Choice 1", "Choice 2" ] })

	inputs[33] = nodeValue_Surface("surfaceBox", self)                             .setDisplay(VALUE_DISPLAY._default)
	
	input_display_list = [
		["Number",  false], 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18,
		["Boolean", false], 19,  
		["Color",   false], 20, 21, 22,
		["Path",    false], 23, 24, 25, 26,
		["Curve",   false], 27,
		["Text",    false], 28, 29, 30, 31, 32,
		["Surface", false], 33,
	];
}