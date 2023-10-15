function AddNodeItem() constructor {
	name = "";
	spr  = noone;
	tags = [];
		
	tooltip	    = "";
	tooltip_spr = noone;
	new_node    = false;
	
	onClick = -1;
	
	static getName    = function() { return name;	 }
	static getTooltip = function() { return tooltip; }	
}

function addNodeItem(list, name, spr, onClick) {
	var item = new AddNodeItem();
	item.name = name;
	item.spr  = spr;
	item.onClick = onClick;
	
	ds_list_add(list, item);
	return item;
}