include <base_params.scad>

module fingers(start, length, x, y) {
	for (p = [start : finger_width * 2 : length]) {
		translate([x + p, y, 0]) {square([finger_width, abs_thick]);}
	}
}

module fingers_b(length, x, y) {
	fingers(0, length, x, y);
}


module fingers_l(height, x, y) {
	translate([abs_thick, 0, 0]) {rotate(90) { fingers(0, height, 0, 0); }}
}

module fingers_r(height, x, y) {
	translate([x - abs_thick, 0, 0]) { fingers_l(height, 0, 0); }
}

module fingers_t(length, x, y) {
	fingers_b(length, x, y - abs_thick);
}

module topbottom2d() {
	difference() {
		square([base_length, base_width]);
		fingers_t(base_length, 0, base_width);
		fingers_b(base_length, 0, 0);
		fingers_l(base_width, 0, 0);
		fingers_r(base_width, base_width, 0);
		}
}

module side2d() {
	difference() {
			square([base_height, base_width]);
			fingers(finger_width, base_height, 0, 0);
			fingers(finger_width, base_height, 0, base_width - abs_thick);
			translate([abs_thick, 0, 0]) {rotate(90) { fingers(finger_width, base_height, 0, 0); }}
			translate([base_height, 0, 0]) {rotate(90) { fingers(finger_width, base_height, 0, 0); }}
			}
}

module frontback2d() {
	difference() {
		square([base_length, base_height]);
		fingers(finger_width, base_length, 0, 0);
		fingers(finger_width, base_length, 0, base_height - abs_thick);
		translate([abs_thick, 0, 0]) {rotate(90) { fingers(0, base_height, 0, 0); }}
		translate([base_width, 0, 0]) {rotate(90) { fingers(0, base_height, 0, 0); }}

	}
}
//147
module top2d() {
	difference() {
		topbottom2d();
		translate([base_length/2, base_width/2, 0]) {circle(bush_outer_d/2);}
	}
}

module acc_side2d() {
	difference() {
		side2d();
		translate([base_height/2, base_width/2, 0]) {circle(valve_diameter/2);}
	}
}

module blank_side2d() {
	side2d();
}

module to3d() {
	linear_extrude(height=abs_thick) { child(0); }
}

module top() {
	translate([0,0,base_height - abs_thick]) {to3d() { top2d(); }}
}

module bottom() {
	to3d() { topbottom2d(); }
}

module acc_side() {
	translate([0,0,base_height]) { rotate(a=[0,90,0]) {to3d() { acc_side2d(); }}}	
}

module blank_side() {
		translate([base_length - abs_thick,0,base_height]) { rotate(a=[0,90,0]) {to3d() { blank_side2d(); }}}
}

module front() {
		translate([0,abs_thick,0]) { rotate(a=[90,0,0]) {to3d() { frontback2d(); }}}
}

module back() {
		translate([0,base_width,0]) { rotate(a=[90,0,0]) {to3d() { frontback2d(); }}}
}

module mme_fix_hole(height) {
		translate([0,0,-0.1]) {cylinder(r = mme_dt/2, h = height + 0.2);}
}

module mme_fix_holes(height) {
		translate([end_to_mounting_hole + mme_lt, (mme_t-mme_tu)/2, 0]) { mme_fix_hole(height); }
		translate([end_to_mounting_hole, (mme_t + mme_tu)/2, 0]) { mme_fix_hole(height); }
}

module mme_port() {
	translate([0,0,-0.1]) {cylinder(r = port_diameter/2, h = 10.2);}
}

// positions of ports and fixing holes are estimates
module mme32() {
	difference() {
		cube([105.6, 22.1, 35.1]);
		mme_fix_holes(35.1);
		translate([end_to_edge_of_port + port_diameter/2, side_to_edge_of_port + port_diameter/2, 0]) { mme_port(); }
		translate([end_to_edge_of_port + port_diameter/2 + mme_lb, side_to_edge_of_port_2 + port_diameter/2, 0]) { mme_port(); }
		translate([end_to_edge_of_top_port + port_diameter/2, side_to_edge_of_top_port + port_diameter/2, 35.1-10.0]) { mme_port(); }
	}
}
union() {
	color([1,2,0,0.5]) {
		union() {
			top();
			bottom();
			acc_side();
			blank_side();
			front();
			back();
		}
	}
	mme32();
}
