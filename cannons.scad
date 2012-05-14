// total diameter of the magazine
outer_d = 75;

// thickness of the magazine walls
wall_l = 8;

// diameter of the holes for the bolts which hold the layers of the magazine together
bolt_d = 3;

// diameter of the holes for the setscrews which position the rounds to be fired next
setscrew_d = 2;

// diameter of the shaft of the bushing
bush_outer_d = 10;

// diameter of the flange of the bushing
bush_flange_d = 14;

// thickness of the flange of the bushing
bush_flange_h = 2;

// thickness of material used for all the layers, except for the layer which accomodates the bushing flange, and the lexan lids
std_thickness = 4;

// thickness of lexan used for the manifold cover and the magazine cover
lexan_h = 1;

// number of barrels
barrel_count = 3;

// riser diameter
riser_d = 6.25;

// riser separation -- horizontal distance between adjacent riser centres
riser_sep = 15;

// length of ramp -- TODO calculate this
ramp_length = 40;


$fn = 100;

module fix_hole(tlate, thickness) {
	hole_center = outer_d/2 - (wall_l/2);
	translate(hole_center * tlate) {
		hole(r = bolt_d/2, h = thickness);
	}
}

module mag_disk(thickness) {
	difference() {
		cylinder(r = outer_d/2, h = thickness);
		fix_hole([-1,0,0], thickness);
		fix_hole([1,0,0], thickness);
		fix_hole([0,1,0], thickness);
		fix_hole([0,-1,0], thickness);
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

module riser_c(n) {
	z = outer_d/2 - wall_l - riser_d/2;
	total_width = riser_sep * (barrel_count - 1);
	y = sqrt(z * z - (total_width/2)*(total_width/2));
	translate([-total_width/2 + riser_sep * n, -y, 0]) {child(0);}
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
		translate([0, ramp_length, 0]) {
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
	difference() {
		mag_disk(std_thickness);
		bush_inner_hole(std_thickness);
		setscrew_holes(std_thickness);
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
		}
	}
}


module ex(n) {
	color ([0.2,0.5,0.5,0.2]) { translate([0, 0, n * outer_d/4 - outer_d]) { child(0); } }
}

ex(0) { base(); }
ex(1) { flange_disk(); }
ex(2) { manifold(); }
ex(3) { manifold_cover(); }
ex(4) { ramps(); }
ex(5) { magazine(); }
ex(6) { manifold_cover(); }