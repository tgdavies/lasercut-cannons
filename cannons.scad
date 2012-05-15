// total diameter of the magazine
outer_d = 75;

// thickness of the magazine walls
wall_l = 8;

// diameter of the holes for the bolts which hold the layers of the magazine together
bolt_d = 3;

// diameter of the holes for the setscrews which position the rounds to be fired next
setscrew_d = 2;

// diameter of the shaft of the bushing
bush_outer_d = 16;

bush_inner_d = 10;

// diameter of the flange of the bushing
bush_flange_d = 20;

// thickness of the flange of the bushing
bush_flange_h = 3;

// length of the bushing tfrom the top of the flange to the end of the shaft
bush_l = 10;

// thickness of material used for all the layers, except for the layer which accomodates the bushing flange, and the lexan lids
std_thickness = 4;

// thickness of lexan used for the manifold cover and the magazine cover
lexan_h = 1;

// number of barrels
barrel_count = 4;

// riser diameter
riser_d = 6.25;

// riser separation -- horizontal distance between adjacent riser centres
riser_sep = 10;


$fn = 100;

module bush() {
	translate([0,0,std_thickness]) {
		difference() {
			union() {
				cylinder(r = bush_flange_d/2, h = bush_flange_h);
				translate([0,0,-(bush_l - bush_flange_h)]) {cylinder(r = bush_outer_d/2, h = (bush_l - bush_flange_h));}
			}
			translate([0,0,-(0.1 + bush_l - bush_flange_h)]) {cylinder(r = bush_inner_d/2, h = bush_l + 0.2);}
		}
	}
}

module fix_hole(tlate, thickness) {
	hole_center = outer_d/2 - (wall_l/2);
	translate(hole_center * tlate) {
		hole(r = bolt_d/2, h = thickness);
	}
}

module fix_holes(thickness) {
	fix_hole([-1,0,0], thickness);
	fix_hole([1,0,0], thickness);
	fix_hole([0,1,0], thickness);
	fix_hole([0,-1,0], thickness);
}

module mag_disk(thickness) {
	difference() {
		cylinder(r = outer_d/2, h = thickness);
		fix_holes(thickness);
	}
};

module hole(r, h) {
	translate([0,0,-0.1]) {
		cylinder(r = r, h = h + 0.2);
	}
}

module bush_inner_hole(thickness) {
	hole(r = bush_outer_d/2, h = thickness);
}

module bush_flange_hole(thickness) {
	hole(r = bush_flange_d/2, h = bush_flange_h);
}

module riser_hole(thickness) {
	hole(r = riser_d/2, h = thickness);
}

function total_riser_width() = riser_sep * (barrel_count - 1);

function riser_z() = outer_d/2 - wall_l - riser_d/2;

function riser_y_size() = sqrt(riser_z() * riser_z() - (total_riser_width()/2)*(total_riser_width()/2));

module riser_c(n) {
	translate([-total_riser_width()/2 + riser_sep * n, -riser_y_size(), 0]) {child(0);}
}

module nth_riser_hole(n, thickness) {
	riser_c(n) {
		riser_hole(thickness);
	}
}

module riser_holes(thickness) {
	for (i = [0 : barrel_count - 1]) {
		nth_riser_hole(i, thickness);
	}
}

module setscrew_hole(n, thickness) {
	riser_c(n) {
		hole(r = setscrew_d/2, h = thickness);
	}
}

module setscrew_holes(thickness) {
	for (i = [0 : barrel_count - 1]) {
		setscrew_hole(i, thickness);
	}
}

module ramp_slot(n, thickness) {
	hull() {
		nth_riser_hole(n, thickness);
		translate([0, 2 * riser_y_size(), 0]) {
			nth_riser_hole(n, thickness);
		}
	}
}

module ramp_slots(thickness) {
	for (i = [0 : barrel_count - 1]) {
		ramp_slot(i, thickness);
	}
}

module base() {
	union() {
		difference() {
			mag_disk(std_thickness);
			bush_inner_hole(std_thickness);
			setscrew_holes(std_thickness);
		}
		bush();
	}
}

module flange_disk() {
	difference() {
		mag_disk(bush_flange_h);
		bush_flange_hole();
		setscrew_holes(std_thickness);
	}
}

module manifold() {
	difference() {
		mag_disk(std_thickness);
		hull() {
			riser_holes(std_thickness);
			bush_inner_hole(std_thickness);
		}
	}
}

module manifold_cover() {
	difference() {
		mag_disk(lexan_h);
		riser_holes(lexan_h);
	}
}

module ramps() {
	difference() {
		mag_disk(std_thickness);
		ramp_slots(std_thickness);
	}
}

module magazine() {
	union() {
		difference() {
			mag_disk(std_thickness);
			hole( r = outer_d / 2 - wall_l, h = std_thickness);
		}
		difference() {
			hull() {
				for (i = [0, barrel_count - 1]) {
					riser_c(i) {cylinder( r = wall_l + riser_d/2, h = std_thickness); }
				}
			}
			riser_holes(std_thickness);
			fix_holes(std_thickness); // because the riser hull can impinge on these
		}
	}
}


module explode() {
	color ([0.2,0.5,0.5,0.3]) {
		for (i = [0 : $children-1]) {
			translate([0, 0, i * outer_d/4 - outer_d]) {
				child(i);
			}
		}
	}
}


explode() {
	base();	
	flange_disk();	
	manifold();	
	manifold_cover();	
	ramps();	
	magazine();	
	manifold_cover();
}
