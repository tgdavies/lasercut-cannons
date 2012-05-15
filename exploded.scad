use <cannons.scad>

barrel_count = 2;

explode() {
	base();	
	flange_disk();	
	manifold();	
	manifold_cover();	
	ramps();	
	magazine();	
	manifold_cover();
}
