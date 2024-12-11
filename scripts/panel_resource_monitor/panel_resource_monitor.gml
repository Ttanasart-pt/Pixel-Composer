function Panel_Resource_Monitor() : PanelContent() constructor {
    title = "ResMon";
	w = ui(380);
	h = ui(48);
	min_h = ui(20);
	
	sysinfo_init();
	
	mb = 1024 * 1024;
	gb = 1024 * 1024 * 1024;
	memory_max = sysinfo_get_memory_max();
	vram_max   = sysinfo_get_gpu_vram();
	cpu_cores  = sysinfo_get_core_count();
	
	memory_use  = 0;
	cpu_uses    = array_create(5);
	cpu_use_ind = 0;
	cpu_use_acc = 0;
	cpu_rec     = 0;
	
	runner = 0;
	
	function drawContent(panel) {
		draw_clear(merge_color(c_black, CDEF.main_dkblack, 0.75));
		draw_clear(COLORS.panel_bg_clear_inner);
		runner++;
		
		if(runner % 100 == 0) {
    		memory_use = sysinfo_proc_memory_used();
    		cpu_use    = sysinfo_sys_cpu_usage();
    		if(cpu_use > 0) {
    		    cpu_use_acc -= cpu_uses[cpu_use_ind];
    		    cpu_uses[cpu_use_ind] = cpu_use;
    		    cpu_use_acc += cpu_use;
    		    cpu_use_ind = (cpu_use_ind + 1) % 5;
    		    cpu_rec++;
    		}
		}
		
		var _cpu = cpu_use_acc / clamp(cpu_rec, 1, 5);
		var _mem = memory_use / memory_max;
		
		draw_sprite_stretched_ext(THEME.s_box_r2, 0, 0, 0, w * _mem, h, COLORS._main_value_positive, 0.2);
		draw_set_text(f_code, fa_left, fa_center, COLORS._main_text);
		
		var _tx = ui(12);
		var _ty = h / 2;
		draw_set_color(COLORS._main_text_sub); draw_text(_tx,          _ty, $"CPU usage"); 
		draw_set_color(COLORS._main_text);     draw_text(_tx + ui(80), _ty, $"{_cpu}%"); 
		
		_tx += ui(160);
		draw_set_color(COLORS._main_text_sub); draw_text(_tx,          _ty, $"Memory");
		draw_set_color(COLORS._main_text);     draw_text(_tx + ui(56), _ty, $"{memory_use / mb} MB");
	}
}