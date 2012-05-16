include <params.scad>

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

module linear_extrude_hole(h) {
	translate([0,0,-0.1]) {
		linear_extrude(height = h + 0.2) {child(0);}
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

function riser_x(n) =
	-total_riser_width()/2 + riser_sep * n;

// you could imagine a layout where riser ys differed
function riser_y(n) =
	-riser_y_size();

module riser_c(n) {
	translate([riser_x(n), riser_y(n), 0]) {child(0);}
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
		//bush();
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

module riser_hull() {
	hull() {
		for (i = [0, barrel_count - 1]) {
			riser_c(i) {hole( r = riser_wall_l + riser_d/2, h = std_thickness); }
		}
	}
}

module magazine_hole() {
	intersection() {
		difference() {
			hole( r = outer_d / 2 - wall_l, h = std_thickness);
			riser_hull();
		}
		fillet_cylinder(std_thickness);
		mirror([1,0,0]) { fillet_cylinder(std_thickness); }
	}
}

module magazine() {
	union() {
		difference() {
			mag_disk(std_thickness);
			magazine_hole();
			riser_holes(std_thickness);
			fix_holes(std_thickness); // because the riser hull can impinge on these
		}
	}
}


module explode() {
	color ([0.2,0.5,0.5,1]) {
		for (i = [0 : $children-1]) {
			translate([0, 0, i * outer_d/4 - outer_d]) {
				child(i);
			}
		}
	}
}

module project() {
	columns = floor(sqrt($children));
	rows = floor($children / columns + 0.5);
	for (row = [0 : rows-1]) {
		for (column = [0 : columns-1]) {
			translate([(outer_d+5)*column, (outer_d+5)*row,0]) {
				projection(cut = true) child(row * columns + column);
			}
		}
	}
}


function circle_contact(p1, p2, r1, r2) =
	p1 + (p2 - p1)*(r1/(r1+r2));

module fillet_cylinder(height) {
// see http://paulbourke.net/geometry/2circle/
// d = distance between center of magazine and center of riser(0)
	rx = riser_x(0);
	ry = riser_y(0);
	d = sqrt(rx * rx + ry * ry);
// r0 radius of circle centered on magazine intersecting centre of fillet circle
	r0 = outer_d / 2 - wall_l - fillet_r;
// r1 radius of circle centered on riser intersecting centre of fillet circle
	r1 = riser_wall_l + riser_d/2 + fillet_r;
	a = (r0*r0 - r1*r1 + d*d ) / (2 * d);
	h = sqrt(r0*r0 - a*a);
// p2 is the point between the intersections
	p2 = [0,0] + a * [rx, ry] / d;
// x3 and y3 is the centre of our circle
	x3 = p2 * [1,0] + h * ry / d;
	y3 = p2 * [0, 1] - h * rx / d;
// now calculate the contact points between the fillet cylinder and the wall and the riser
	c1 = circle_contact([x3, y3], [0,0], -fillet_r, outer_d / 2 - wall_l);
	c2 = circle_contact([x3, y3], [rx, ry], fillet_r, riser_wall_l + riser_d/2);
	diff = c1 - c2;
	slope = (diff * [0,1])/(diff * [1, 0]);
	union() {
		translate([x3,y3,0]) {
			hole(r = fillet_r, h = height);
		}
		linear_extrude_hole(h = height) {polygon(points = [c1 + [-100, -100 * slope], c2 + [100, 100 * slope], [0,100]]);}
	}
}

magazine();

/*project() {
	base();
	manifold();
	ramps();
	magazine();
}*/


/*explode() {
	base();	
	flange_disk();	
	manifold();	
	manifold_cover();	
	ramps();	
	magazine();	
	manifold_cover();
}*/
