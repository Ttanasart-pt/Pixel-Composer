#define lua_script_execute
/// (script:index, args:array, argc:int)~
if (argument2 < global.g_lua_script_execute_max) {
	return script_execute(global.g_lua_script_execute[argument2], argument0, argument1);
} else show_error("lua_script_execute: Too many arguments (got " + string(argument2) + ", max " + string(global.g_lua_script_execute_max) + ")!", false);

/* // generator:
var r = ``;
for (var i = 0; i <= 32; i++) {
r += `#define lua_script_execute_${i}
return script_execute(argument0`;
for (var k = 0; k < i; k++) r += `, argument1[${k}]`;
r += `);\n`;
}; r;
*/

#define lua_script_execute_0
return script_execute(argument0);
#define lua_script_execute_1
return script_execute(argument0, argument1[0]);
#define lua_script_execute_2
return script_execute(argument0, argument1[0], argument1[1]);
#define lua_script_execute_3
return script_execute(argument0, argument1[0], argument1[1], argument1[2]);
#define lua_script_execute_4
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3]);
#define lua_script_execute_5
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4]);
#define lua_script_execute_6
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5]);
#define lua_script_execute_7
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6]);
#define lua_script_execute_8
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7]);
#define lua_script_execute_9
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8]);
#define lua_script_execute_10
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9]);
#define lua_script_execute_11
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10]);
#define lua_script_execute_12
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11]);
#define lua_script_execute_13
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12]);
#define lua_script_execute_14
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13]);
#define lua_script_execute_15
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14]);
#define lua_script_execute_16
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15]);
#define lua_script_execute_17
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16]);
#define lua_script_execute_18
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17]);
#define lua_script_execute_19
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18]);
#define lua_script_execute_20
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19]);
#define lua_script_execute_21
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20]);
#define lua_script_execute_22
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20], argument1[21]);
#define lua_script_execute_23
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20], argument1[21], argument1[22]);
#define lua_script_execute_24
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20], argument1[21], argument1[22], argument1[23]);
#define lua_script_execute_25
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20], argument1[21], argument1[22], argument1[23], argument1[24]);
#define lua_script_execute_26
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20], argument1[21], argument1[22], argument1[23], argument1[24], argument1[25]);
#define lua_script_execute_27
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20], argument1[21], argument1[22], argument1[23], argument1[24], argument1[25], argument1[26]);
#define lua_script_execute_28
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20], argument1[21], argument1[22], argument1[23], argument1[24], argument1[25], argument1[26], argument1[27]);
#define lua_script_execute_29
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20], argument1[21], argument1[22], argument1[23], argument1[24], argument1[25], argument1[26], argument1[27], argument1[28]);
#define lua_script_execute_30
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20], argument1[21], argument1[22], argument1[23], argument1[24], argument1[25], argument1[26], argument1[27], argument1[28], argument1[29]);
#define lua_script_execute_31
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20], argument1[21], argument1[22], argument1[23], argument1[24], argument1[25], argument1[26], argument1[27], argument1[28], argument1[29], argument1[30]);
#define lua_script_execute_32
return script_execute(argument0, argument1[0], argument1[1], argument1[2], argument1[3], argument1[4], argument1[5], argument1[6], argument1[7], argument1[8], argument1[9], argument1[10], argument1[11], argument1[12], argument1[13], argument1[14], argument1[15], argument1[16], argument1[17], argument1[18], argument1[19], argument1[20], argument1[21], argument1[22], argument1[23], argument1[24], argument1[25], argument1[26], argument1[27], argument1[28], argument1[29], argument1[30], argument1[31]);