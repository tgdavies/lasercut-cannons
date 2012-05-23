include <params.scad>

finger_width = 5;

function finger_count(l) = floor(l/finger_width) + (l % finger_width == 0 ? 0 : 1);

function next_odd(n) = n % 2 == 0 ? n + 1 : n;

function fingerable(x) = next_odd(finger_count(x)) * finger_width;


// diameter of the hole for the buna ball valve
valve_diameter = 12.5;

// diameter of the hole for mounting the mpa-7
mpa7_diameter = 10; //????

// accumulator inner diameter
acc_inner_d = 25.4;

// accumulator outer diameter
acc_outer_d = 35; //?

// thickness of ABS sheet
abs_thick = 5;

// clearance from hole in ABS to edge
abs_clearance = 5;

base_length = fingerable(bush_outer_d + abs_clearance * 2 + abs_thick * 2);

base_width = fingerable(bush_outer_d + abs_clearance * 2 + abs_thick * 2);

base_height = fingerable(acc_inner_d + abs_clearance * 2 + abs_thick * 2);