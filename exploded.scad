use <cannons.scad>

explode() {
	base();	
	flange_disk();	
	manifold();	
	color([1,1,0,0.5]) {manifold_cover();	}
	ramps();	
	magazine();	
	color([1,1,0,0.5]) {manifold_cover();	}}
