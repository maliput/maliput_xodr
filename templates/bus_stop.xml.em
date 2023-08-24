<?xml version="1.0" encoding="UTF-8"?>
<!--
 BSD 3-Clause License

 Copyright (c) 2023, Woven by Toyota. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

 * Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-->
@{
import em
import math as m
import os
import uuid

import pyproj

# Georeference information
LAT_0 = 37.4168716
LON_0 = -122.1030492

def str2bool(string):
  return string.lower() in ("yes", "true", "t", "1")

def str2float(string):
  return float(string)

def cartesian_to_geodetic(x, y, z, origin_lon, origin_lat):
    # Define the projection systems
    geodetic_crs = pyproj.CRS.from_string("EPSG:4326")  # Geodetic (lon, lat) system (WGS84)
    projection_crs = pyproj.CRS.from_string(f"+proj=tmerc +lat_0={origin_lat} +lon_0={origin_lon} +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs")  # Cartesian (x, y, z) system with tmerc projection (WGS84)

    # Create the transformer
    transformer = pyproj.Transformer.from_crs(projection_crs, geodetic_crs, always_xy=True)

    # Convert Cartesian coordinates to geodetic
    target_lon, target_lat, target_z = transformer.transform(x, y, z)

    return target_lon, target_lat, target_z

def to_lon_lat_points(points):
    lon_lat_points = []
    for point in points:
        lon, lat, h = cartesian_to_geodetic(point[0], point[1], 0, LON_0, LAT_0)
        lon_lat_points.append([lon, lat, h])
    return lon_lat_points

width = str2float(os.environ['WIDTH']) if 'WIDTH' in os.environ  else 4.0
bus_stop_length = str2float(os.environ['BUS_STOP_LENGTH']) if 'BUS_STOP_LENGTH' in os.environ  else 15.
extensions_length = str2float(os.environ['EXTENSIONS_LENGTH']) if 'EXTENSIONS_LENGTH' in os.environ  else 30.
x_offset = str2float(os.environ['X_OFFSET']) if 'X_OFFSET' in os.environ  else 0.0
y_offset = str2float(os.environ['Y_OFFSET']) if 'Y_OFFSET' in os.environ  else 0.0

# Map
#                     bus stop lane (special1)
#                    |----------->|
# south  ------------|----------->|----------->     North
#        <-----------|<-----------|------------
#
#          Section1     Section2     Section3

road_1_length = 2 * extensions_length + bus_stop_length
road_1_hdg = m.pi/2.

road_1_start = [0. + x_offset, 0. + y_offset]
road_1_end = [road_1_start[0], road_1_start[1] + road_1_length]

lane_section_1_length = extensions_length
lane_section_2_length = bus_stop_length
lane_section_3_length = extensions_length

lane_section_1_end = [road_1_start[0], road_1_start[1] + lane_section_1_length]
lane_section_1_s0 = 0.

lane_section_2_start = lane_section_1_end
lane_section_2_end = [lane_section_2_start[0], lane_section_2_start[1] + lane_section_2_length]
lane_section_2_s0 = lane_section_1_length

lane_section_3_start = lane_section_2_end
lane_section_3_end = [lane_section_3_start[0], lane_section_3_start[1] + lane_section_3_length]
lane_section_3_s0 = lane_section_2_length + lane_section_1_length

# For geojson generation
bus_lane_boundary_left_start = [lane_section_2_start[0] - 2 * width, lane_section_2_start[1]]
bus_lane_boundary_left_end = [lane_section_2_end[0] - 2 * width, lane_section_2_end[1]]
bus_lane_boundary_left_points = [bus_lane_boundary_left_start, bus_lane_boundary_left_end]
bus_lane_boundary_left_points_lon_lat = to_lon_lat_points(bus_lane_boundary_left_points)

bus_lane_boundary_right_start = [lane_section_2_start[0] - width, lane_section_2_start[1]]
bus_lane_boundary_right_end = [lane_section_2_end[0] - width, lane_section_2_end[1]]
bus_lane_boundary_right_points = [bus_lane_boundary_right_start, bus_lane_boundary_right_end]
bus_lane_boundary_right_points_lon_lat = to_lon_lat_points(bus_lane_boundary_right_points)

bus_lane_center_start = [bus_lane_boundary_left_start[0] + width / 2., bus_lane_boundary_left_start[1]]
bus_lane_center_end = [bus_lane_boundary_left_end[0] + width / 2., bus_lane_boundary_left_end[1]]
bus_lane_center_points = [bus_lane_center_start, bus_lane_center_end]
bus_lane_center_points_lon_lat = to_lon_lat_points(bus_lane_center_points)

bus_lane_id = str(uuid.uuid4())
bus_lane_boundary_left_id = str(uuid.uuid4())
bus_lane_boundary_right_id = str(uuid.uuid4())



}@
<!--
 Map generated using:
  - WIDTH: @(width)@ 
  - EXTENSIONS_LENGTH: @(extensions_length)@ 
  - BUS_STOP_LENGTH: @(bus_stop_length)@ 
  - OFFSET_X: @(x_offset)@ 
  - OFFSET_Y: @(y_offset)@ 
-->
<OpenDRIVE>
    <header revMajor="1" revMinor="1" name="BusStopLane" version="1.00" date="Thu Aug 24 12:00:00 2023" north="0.0000000000000000e+00" south="0.0000000000000000e+00" east="0.0000000000000000e+00" west="0.0000000000000000e+00" maxRoad="2" maxJunc="0" maxPrg="0">
        <geoReference><![CDATA[+proj=tmerc +lat_0=@(LAT_0)@  +lon_0=@(LON_0)@  +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +vunits=m +no_defs ]]></geoReference>
    </header>
    <road name="Road 1" length="@(road_1_length)@\" id="1" junction="-1">
        <link>
        </link>
        <planView>
            <geometry s="@(lane_section_1_s0)@\" x="@(road_1_start[0])@\" y="@(road_1_start[1])@\" hdg="@(road_1_hdg)@\" length="@(lane_section_1_length)@\">
                <line/>
            </geometry>
            <geometry s="@(lane_section_2_s0)@\" x="@(lane_section_2_start[0])@\" y="@(lane_section_2_start[1])@\" hdg="@(road_1_hdg)@\" length="@(lane_section_2_length)@\">
                <line/>
            </geometry>
            <geometry s="@(lane_section_3_s0)@\" x="@(lane_section_3_start[0])@\" y="@(lane_section_3_start[1])@\" hdg="@(road_1_hdg)@\" length="@(lane_section_3_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="@(lane_section_1_s0)@\">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
            <laneSection s="@(lane_section_2_s0)@\">
                <left>
                    <lane id="2" type="special1" level= "0">
                        <link>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <predecessor id="1"/>
                            <successor id="1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <predecessor id="-1"/>
                            <successor id="-1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
            <laneSection s="@(lane_section_3_s0)@\">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <predecessor id="1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="forward"/>
                        </userData>
                    </lane>
                </left>
                <center>
                    <lane id="0" type="none" level= "0">
                        <link>
                        </link>
                        <roadMark sOffset="0.0000000000000000e+00" type="broken" weight="standard" color="standard" width="1.3000000000000000e-01"/>
                    </lane>
                </center>
                <right>
                    <lane id="-1" type="driving" level= "0">
                        <link>
                            <predecessor id="-1"/>
                        </link>
                        <width sOffset="0.0000000000000000e+00" a="@(width)@\" b="0.0000000000000000e+00" c="0.0000000000000000e+00" d="0.0000000000000000e+00"/>
                        <roadMark sOffset="0.0000000000000000e+00" type="solid" weight="standard" color="standard" width="1.0000000000000000e-01"/>
                        <userData>
                            <vectorLane travelDir="backward"/>
                        </userData>
                    </lane>
                </right>
            </laneSection>
        </lanes>
    </road>
</OpenDRIVE>
<!-- GeoJSON information for the crosswalks
Generated GeoJSON can be verified using: https://geojson.io
@{
}@

{
  "features": [
    {
      "geometry": {
        "coordinates": [
@[for idx, lon_lat_z in enumerate(bus_lane_center_points_lon_lat)]@
          [
            @(lon_lat_z[0]),
            @(lon_lat_z[1]),
            @(lon_lat_z[2])
          ]@[if (idx != len(bus_lane_center_points_lon_lat)-1)],@[end if]
@[end for ]@
        ],
        "type": "LineString"
      },
      "properties": {
        "Id": "{@(bus_lane_id)}",
        "LaneType": "Special 1",
        "LeftBoundary": {
          "Dir": "Forward",
          "Id": "{@(bus_lane_boundary_left_id)}"
        },
        "RightBoundary": {
          "Dir": "Forward",
          "Id": "{@(bus_lane_boundary_right_id)}"
        },
        "Predecessors": [],
        "Successors": [],
        "TravelDir": "Undirected",
        "Type": "Lane"
      },
      "type": "Feature"
    },
    {
      "geometry": {
        "coordinates": [
@[for idx, lon_lat_z in enumerate(bus_lane_boundary_right_points_lon_lat)]@
          [
            @(lon_lat_z[0]),
            @(lon_lat_z[1]),
            @(lon_lat_z[2])
          ]@[if (idx != len(bus_lane_boundary_right_points_lon_lat)-1)],@[end if]
@[end for ]@
        ],
        "type": "LineString"
      },
      "properties": {
        "Id": "{@(bus_lane_boundary_right_id)}",
        "RightLane": {
          "Dir": "Forward",
          "Id": "{bus_lane_id}"
        },
        "Type": "LaneBoundary"
      },
      "type": "Feature"
    },
    {
      "geometry": {
        "coordinates": [
@[for idx, lon_lat_z in enumerate(bus_lane_boundary_left_points_lon_lat)]@
          [
            @(lon_lat_z[0]),
            @(lon_lat_z[1]),
            @(lon_lat_z[2])
          ]@[if (idx != len(bus_lane_boundary_left_points_lon_lat)-1)],@[end if]
@[end for ]@
        ],
        "type": "LineString"
      },
      "properties": {
        "Id": "{@(bus_lane_boundary_left_id)}",
        "LeftLane": {
          "Dir": "Forward",
          "Id": "{bus_lane_id}"
        },
        "Type": "LaneBoundary"
      },
      "type": "Feature"
    }
  ],
  "type": "FeatureCollection"
}
-->
