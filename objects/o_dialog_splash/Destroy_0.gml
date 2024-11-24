/// @description 
event_inherited();

run_in(1, function() /*=>*/ {
	ds_map_destroy(discord_map);
	ds_map_destroy(nicknames);
	ds_map_destroy(attachment);
	
	surface_free(clip_surf);
	
	sp_recent.free();
	sp_sample.free();
	sp_contest.free();
	sp_news.free();
});