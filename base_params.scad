include <params.scad>

finger_width = 4;

function finger_count(l) = floor(l/finger_width) + (l % finger_width == 0 ? 0 : 1);

function next_odd(n) = n % 2 == 0 ? n + 1 : n;

function fingerable(x) = next_odd(finger_count(x)) * finger_width;

// accumulator inner diameter
acc_inner_d = 25.4;

// accumulator outer diameter
acc_outer_d = 35; //?

// thickness of ABS sheet
abs_thick = 4.5;

// clearance from hole in ABS to edge
abs_clearance = 5;

npt14hole = 0.54 * 25.4;

// mme 32 parameters
//  +---------------------------------------+
//  |                                       |
//  |               TOP                     | width
//  |                                       |
//  +---------------------------------------+
//                length

mme_dt = 3.3; // mounting hole diameter
mme_t = 22.1; // width of valve body
mme_tu = 16.5; // vertical distance between mounting hole centers
mme_lb = 18; // horizontal distance between bottom port centers
mme_lt = 33; // horizontal distance between mounting hole centres
end_to_mounting_hole = 12.6;
port_diameter = 11.445;
end_to_edge_of_port = 14.337;
side_to_edge_of_port = 3.828;
side_to_edge_of_port_2 = 6.828;
side_to_edge_of_top_port = 3.828;
end_to_edge_of_top_port = 23.379;

// height required to attach to an MME valve
mme_height = mme_tu + abs_clearance * 2 + mme_dt;
mme_width = mme_lb + abs_clearance * 2 + npt14hole;

base_length = fingerable(bush_outer_d + abs_clearance * 2 + abs_thick * 2);

base_width = fingerable(max(bush_outer_d + abs_clearance * 2 + abs_thick * 2, mme_width));

base_height = fingerable(mme_height);

echo(Width = base_width, Length = base_length, Height = base_height);