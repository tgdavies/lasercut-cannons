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
//139
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

module mpa7_side2d() {
	difference() {
		side2d();
		translate([base_height/2, base_width/2, 0]) {circle(mpa7_diameter/2);}
	}
}

module acc_mount_ring2d() {
	difference() {
		circle(acc_inner_d/2);
		circle(valve_diameter/2);
	}
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
	union() {
		translate([0,0,base_height]) { rotate(a=[0,90,0]) {to3d() { acc_side2d(); }}}
		translate([-abs_thick,0,base_height]) { rotate(a=[0,90,0]) {to3d() {
			translate([base_height/2, base_width/2]) {acc_mount_ring2d();}
		}}}		
	}
}

module mpa7_side() {
		translate([base_length - abs_thick,0,base_height]) { rotate(a=[0,90,0]) {to3d() { mpa7_side2d(); }}}
}

module front() {
		translate([0,abs_thick,0]) { rotate(a=[90,0,0]) {to3d() { frontback2d(); }}}
}

module back() {
		translate([0,base_width,0]) { rotate(a=[90,0,0]) {to3d() { frontback2d(); }}}
}

color([1,2,0,0.5]) {
	union() {
		top();
		bottom();
		acc_side();
		mpa7_side();
		front();
		back();
	}
}
