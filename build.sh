#!/bin/sh

echo "Creating DXF files from cannons.scad..."

for i in std_thickness flange_thickness lexan
do
	echo "Creating DXF file for $i layer"
	OpenSCAD -o $i.dxf $i.scad
done
