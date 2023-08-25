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
import os
import math as m

def str2bool(string):
  return string.lower() in ("yes", "true", "t", "1")

def str2float(string):
  return float(string)

def sqrtdistance(p1:list, p2:list):
  return m.sqrt((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)

# Georeference information
LAT_0 = 37.4168716
LON_0 = -122.1030492

# Origin offset
x_offset = str2float(os.environ['X_OFFSET']) if 'X_OFFSET' in os.environ  else 0.0
y_offset = str2float(os.environ['Y_OFFSET']) if 'Y_OFFSET' in os.environ  else 0.0
# Width of the lanes
width = str2float(os.environ['WIDTH']) if 'WIDTH' in os.environ  else 3.0
# Radius of the junction
radius = str2float(os.environ['RADIUS']) if 'RADIUS' in os.environ else 8.0
# Whether to add crosswalks
crosswalk = str2bool(os.environ['CROSSWALK']) if 'CROSSWALK' in os.environ else False
# crosswalk length
crosswalk_length = str2float(os.environ['CROSSWALK_LENGTH']) if 'CROSSWALK_LENGTH' in os.environ else 2.0
# stopline
stopline = str2bool(os.environ['STOPLINE']) if 'STOPLINE' in os.environ else False

# No junction roads
#          2
#          |
#          |
#          |
#          v
# 1----->     <-----3
#          ^
#          |
#          |
#          |
#          4
#
road_1_start = [0. + x_offset, 0. + y_offset]
road_1_end = [100. + x_offset, 0. + y_offset]

road_2_start = [100. + radius + width + x_offset, 100. + radius + width + y_offset]
road_2_end   = [100. + radius + width + x_offset,        radius + width + y_offset]

road_3_start = [100. + 2*radius + 2*width + 100. + x_offset, 0. + y_offset]
road_3_end   = [100. + 2*radius + 2*width        + x_offset, 0. + y_offset]

road_4_start = [100. + radius + width + x_offset, -100. - radius - width + y_offset]
road_4_end   = [100. + radius + width + x_offset,       - radius - width + y_offset]

# Junction roads

# East-West Road
road_5_start = road_1_end
road_5_end   = road_3_end
road_5_length = sqrtdistance(road_5_start, road_5_end)
# North-South Road
road_6_start = road_2_end
road_6_end   = road_4_end
road_6_length = sqrtdistance(road_6_start, road_6_end)
# East-North Road
road_7_start = road_1_end
road_7_radius = radius + width
road_7_curvature = 1./road_7_radius
road_7_length = road_7_radius * m.pi / 2. # 90 degrees of curvature
# East-South Road
road_8_start = road_1_end
road_8_radius = radius + width
road_8_curvature = 1./road_8_radius
road_8_length = road_8_radius * m.pi / 2. # 90 degrees of curvature
# West-North Road
road_9_start = road_3_end
road_9_radius = radius + width
road_9_curvature = 1./road_9_radius
road_9_length = road_9_radius * m.pi / 2. # 90 degrees of curvature
# West-South Road
road_10_start = road_3_end
road_10_radius = radius + width
road_10_curvature = 1./road_10_radius
road_10_length = road_10_radius * m.pi / 2. # 90 degrees of curvature

if crosswalk or stopline:
  import pyproj
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
      lon_lat_points.append(lon_lat_points[0]) # GeoJSON format needs closure
      return lon_lat_points

  def quadratic_solver(a, b, c):
      delta = b * b - 4 * a * c
      if delta < 0:
          return None
      elif delta == 0:
          return [-b / (2 * a), -b / (2 * a)]
      else:
          return [(-b + m.sqrt(delta)) / (2 * a), (-b - m.sqrt(delta)) / (2 * a)]

  if crosswalk:
    ################
    ## CROSSWALKS ##
    ################

    ## Using the quadratic formula to find the extrusion length of the crosswalk.
    ## This is calculated combining the arc length with circunference equation.
    b = 2 * radius
    c = crosswalk_length * crosswalk_length
    roots_left = quadratic_solver(1, b, c)
    roots_right = quadratic_solver(1, -b, c)
    if roots_left is None or roots_right is None:
        raise Exception("Error: Probably the crosswalk length is too long for the given radius")
    extrusion_right = abs(min(roots_right))
    extrusion_left = abs(max(roots_left))
    # by symetry the abs value of left and right extrusion are equal
    assert abs(extrusion_left - extrusion_right) < 1e-6

    ## Calculate corners of the crosswalk
    ## West Crosswalk
    crosswalk_west_points = [[road_5_start[0], road_5_start[1] + width],
                            [road_5_start[0], road_5_start[1] - width],
                            [road_5_start[0] + crosswalk_length, road_5_start[1] - width - extrusion_right],
                            [road_5_start[0] + crosswalk_length, road_5_start[1] + width + extrusion_left],
                            ]


    ## East Crosswalk
    crosswalk_east_points = [[road_5_end[0] - crosswalk_length, road_5_end[1] + width + extrusion_left],
                            [road_5_end[0] - crosswalk_length, road_5_end[1] - width - extrusion_left],
                            [road_5_end[0], road_5_end[1] - width],
                            [road_5_end[0], road_5_end[1] + width],
                            ]


    ## North Crosswalk
    crosswalk_north_points = [[road_6_start[0] + width, road_6_start[1]],
                            [road_6_start[0] - width, road_6_start[1]],
                            [road_6_start[0] - width - extrusion_right, road_6_start[1] - crosswalk_length],
                            [road_6_start[0] + width + extrusion_left, road_6_start[1] - crosswalk_length],
                            ]


    ## South Crosswalk
    crosswalk_south_points = [[road_6_end[0] + width + extrusion_left, road_6_end[1] + crosswalk_length],
                            [road_6_end[0] - width - extrusion_left , road_6_end[1] + crosswalk_length],
                            [road_6_end[0] - width, road_6_end[1]],
                            [road_6_end[0] + width, road_6_end[1]],
                            ]
    crosswalk_west_points_lon_lat = to_lon_lat_points(crosswalk_west_points)
    crosswalk_east_points_lon_lat = to_lon_lat_points(crosswalk_east_points)
    crosswalk_north_points_lon_lat = to_lon_lat_points(crosswalk_north_points)
    crosswalk_south_points_lon_lat = to_lon_lat_points(crosswalk_south_points)

  if stopline:
    ###############
    ## STOPLINES ##
    ###############
    stopline_west_points = [
      [road_1_end[0], road_1_end[1] + width],
      [road_1_end[0], road_1_end[1]],
    ]
    stopline_east_points = [
      [road_3_end[0], road_3_end[1] - width],
      [road_3_end[0], road_3_end[1]],
    ]
    stopline_west_points_lon_lat = to_lon_lat_points(stopline_west_points)
    stopline_east_points_lon_lat = to_lon_lat_points(stopline_east_points)
}@
<!--
 Map generated using https://github.com/maliput/maliput_xodr.
 Generated using the following parameters:
  - WIDTH: @(width)@ 
    - Indicates the width of the lane
  - RADIUS: @(radius)@ 
    - Indicates the radius of the intersection
  - CROSSWALK: @(crosswalk)@ 
    - Indicates if crosswalks are generated
  - CROSSWALK_LENGTH: @(crosswalk_length)@ 
    - Indicates the length of the crosswalks
  - STOPLINE: @(stopline)@ 
    - Indicates if stoplines are generated(for east west directions only)(it only affects geoJSON info)
  - OFFSET_X: @(x_offset)@ 
    - Indicates the offset in the x axis of the openDRIVE map
  - OFFSET_Y: @(y_offset)@ 
    - Indicates the offset in the y axis of the openDRIVE map
-->
<OpenDRIVE>
    <header revMajor="1" revMinor="1" name="Intersection" version="1.00" date="Fri Apr 28 12:00:00 2023" north="0.0000000000000000e+00" south="0.0000000000000000e+00" east="0.0000000000000000e+00" west="0.0000000000000000e+00" maxRoad="2" maxJunc="0" maxPrg="0">
        <geoReference><![CDATA[+proj=tmerc +lat_0=@(LAT_0)@  +lon_0=@(LON_0)@  +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +vunits=m +no_defs ]]></geoReference>
    </header>
    <road name="Road 1" length="100.0" id="1" junction="-1">
        <link>
            <successor elementType="junction" elementId="2"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_1_start[0])@\" y="@(road_1_start[1])@\" hdg="0.0" length="100.0">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
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
    <road name="Road 2" length="100.0" id="2" junction="-1">
        <link>
            <successor elementType="junction" elementId="2"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_2_start[0])@\" y="@(road_2_start[1])@\" hdg="@(-m.pi/2.)@\" length="100.0">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
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
    <road name="Road 3" length="100.0" id="3" junction="-1">
        <link>
            <successor elementType="junction" elementId="2"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_3_start[0])@\" y="@(road_3_start[1])@\" hdg="@(-m.pi)@\" length="100.0">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
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
    <road name="Road 4" length="100.0" id="4" junction="-1">
        <link>
            <successor elementType="junction" elementId="2"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_4_start[0])@\" y="@(road_4_start[1])@\" hdg="@(m.pi/2.)@\" length="100.0">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
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
    <road name="Road 5" length="@(road_5_length)@\" id="5" junction="2">
        <link>
            <predecessor elementType="road" elementId="1" contactPoint="end"/>
            <successor elementType="road" elementId="3" contactPoint="end"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_5_start[0])@\" y="@(road_5_start[1])@\" hdg="0.0" length="@(road_5_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <predecessor id="1"/>
                            <successor id="-1"/>
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
                            <successor id="1"/>
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
        @[if crosswalk]<objects>
            <object type="crosswalk" id="0" s="0.0" t="0.0" zOffset="0.0" orientation="none" length="@(crosswalk_length)@\" width="@(width * 2)@\" hdg="0.0" pitch="0.0" roll="0.0">
                <outlines>
                    <outline id="0">
                        <cornerRoad s="0.0" t="@(width)@\" dz="0.0" height="4.0" id="0"/>
                        <cornerRoad s="0.0" t="-@(width)@\" dz="0.0" height="4.0" id="1"/>
                        <cornerRoad s="@(crosswalk_length)@\" t="-@(width+extrusion_right)@\" dz="0.0" height="4.0" id="2"/>
                        <cornerRoad s="@(crosswalk_length)@\" t="@(width+extrusion_left)@\" dz="0.0" height="4.0" id="3"/>
                    </outline>
                </outlines>
                <markings>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="0"/>
                        <cornerReference id="1"/>
                    </marking>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="2"/>
                        <cornerReference id="3"/>
                    </marking>
                </markings>
            </object>
            <object type="crosswalk" id="0" s="@(road_5_length - crosswalk_length)@\" t="0.0" zOffset="0.0" orientation="none" length="@(crosswalk_length)@\" width="@(width * 2)@\" hdg="0.0" pitch="0.0" roll="0.0">
                <outlines>
                    <outline id="0">
                        <cornerRoad s="@(road_5_length - crosswalk_length)@\" t="@(width+extrusion_left)@\" dz="0.0" height="4.0" id="0"/>
                        <cornerRoad s="@(road_5_length - crosswalk_length)@\" t="-@(width+extrusion_right)@\" dz="0.0" height="4.0" id="1"/>
                        <cornerRoad s="@(road_5_length)@\" t="-@(width)@\" dz="0.0" height="4.0" id="2"/>
                        <cornerRoad s="@(road_5_length)@\" t="@(width)@\" dz="0.0" height="4.0" id="3"/>
                    </outline>
                </outlines>
                <markings>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="0"/>
                        <cornerReference id="1"/>
                    </marking>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="2"/>
                        <cornerReference id="3"/>
                    </marking>
                </markings>
            </object>
        </objects>@[else]<objects>
        </objects>@[end if]
    </road>
    <road name="Road 6" length="@(road_6_length)@\" id="6" junction="2">
        <link>
            <predecessor elementType="road" elementId="2" contactPoint="end"/>
            <successor elementType="road" elementId="4" contactPoint="end"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_6_start[0])@\" y="@(road_6_start[1])@\" hdg="@(-m.pi/2.)@\" length="@(road_6_length)@\">
                <line/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <predecessor id="1"/>
                            <successor id="-1"/>
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
                            <successor id="1"/>
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
        @[if crosswalk]<objects>
            <object type="crosswalk" id="0" s="0.0" t="0.0" zOffset="0.0" orientation="none" length="@(crosswalk_length)@\" width="@(width * 2)@\" hdg="0.0" pitch="0.0" roll="0.0">
                <outlines>
                    <outline id="0">
                        <cornerRoad s="0.0" t="@(width)@\" dz="0.0" height="4.0" id="0"/>
                        <cornerRoad s="0.0" t="-@(width)@\" dz="0.0" height="4.0" id="1"/>
                        <cornerRoad s="@(crosswalk_length)@\" t="-@(width+extrusion_right)@\" dz="0.0" height="4.0" id="2"/>
                        <cornerRoad s="@(crosswalk_length)@\" t="@(width+extrusion_left)@\" dz="0.0" height="4.0" id="3"/>
                    </outline>
                </outlines>
                <markings>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="0"/>
                        <cornerReference id="1"/>
                    </marking>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="2"/>
                        <cornerReference id="3"/>
                    </marking>
                </markings>
            </object>
            <object type="crosswalk" id="0" s="@(road_6_length - crosswalk_length)@\" t="0.0" zOffset="0.0" orientation="none" length="@(crosswalk_length)@\" width="@(width * 2)@\" hdg="0.0" pitch="0.0" roll="0.0">
                <outlines>
                    <outline id="0">
                        <cornerRoad s="@(road_6_length - crosswalk_length)@\" t="@(width+extrusion_left)@\" dz="0.0" height="4.0" id="0"/>
                        <cornerRoad s="@(road_6_length - crosswalk_length)@\" t="-@(width+extrusion_right)@\" dz="0.0" height="4.0" id="1"/>
                        <cornerRoad s="@(road_6_length)@\" t="-@(width)@\" dz="0.0" height="4.0" id="2"/>
                        <cornerRoad s="@(road_6_length)@\" t="@(width)@\" dz="0.0" height="4.0" id="3"/>
                    </outline>
                </outlines>
                <markings>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="0"/>
                        <cornerReference id="1"/>
                    </marking>
                    <marking width="0.1" color="white" zOffset="0.005" spaceLength ="0.05" lineLength ="0.2" startOffset="0.0" stopOffset="0.0" outlineId="0">
                        <cornerReference id="2"/>
                        <cornerReference id="3"/>
                    </marking>
                </markings>
            </object>
        </objects>@[else]<objects>
        </objects>@[end if]
    </road>
    <road name="Road 7" length="@(road_7_length)@\" id="7" junction="2">
        <link>
            <predecessor elementType="road" elementId="1" contactPoint="end"/>
            <successor elementType="road" elementId="2" contactPoint="end"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_7_start[0])@\" y="@(road_7_start[1])@\" hdg="0.0" length="@(road_7_length)@\">
                <arc curvature="@(road_7_curvature)@\"/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <predecessor id="1"/>
                            <successor id="-1"/>
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
                            <successor id="1"/>
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
    <road name="Road 8" length="@(road_8_length)@\" id="8" junction="2">
        <link>
            <predecessor elementType="road" elementId="1" contactPoint="end"/>
            <successor elementType="road" elementId="4" contactPoint="end"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_8_start[0])@\" y="@(road_8_start[1])@\" hdg="0.0" length="@(road_8_length)@\">
                <arc curvature="@(-road_8_curvature)@\"/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <predecessor id="1"/>
                            <successor id="-1"/>
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
                            <successor id="1"/>
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
    <road name="Road 9" length="@(road_9_length)@\" id="9" junction="2">
        <link>
            <predecessor elementType="road" elementId="3" contactPoint="end"/>
            <successor elementType="road" elementId="2" contactPoint="end"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_9_start[0])@\" y="@(road_9_start[1])@\" hdg="@(-m.pi)@\" length="@(road_9_length)@\">
                <arc curvature="@(-road_9_curvature)@\"/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <predecessor id="1"/>
                            <successor id="-1"/>
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
                            <successor id="1"/>
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
    <road name="Road 10" length="@(road_10_length)@\" id="10" junction="2">
        <link>
            <predecessor elementType="road" elementId="3" contactPoint="end"/>
            <successor elementType="road" elementId="4" contactPoint="end"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_10_start[0])@\" y="@(road_10_start[1])@\" hdg="@(-m.pi)@\" length="@(road_10_length)@\">
                <arc curvature="@(road_10_curvature)@\"/>
            </geometry>
        </planView>
        <elevationProfile>
        </elevationProfile>
        <lateralProfile>
        </lateralProfile>
        <lanes>
            <laneSection s="0.0000000000000000e+00">
                <left>
                    <lane id="1" type="driving" level= "0">
                        <link>
                            <predecessor id="1"/>
                            <successor id="-1"/>
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
                            <successor id="1"/>
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
    <junction id="2" name="">
        <connection id="0" incomingRoad="1" connectingRoad="5" contactPoint="start">
            <laneLink from="1" to="1"/>
            <laneLink from="-1" to="-1"/>
        </connection>
        <connection id="1" incomingRoad="2" connectingRoad="6" contactPoint="start">
            <laneLink from="1" to="1"/>
            <laneLink from="-1" to="-1"/>
        </connection>
        <connection id="2" incomingRoad="1" connectingRoad="7" contactPoint="start">
            <laneLink from="1" to="1"/>
            <laneLink from="-1" to="-1"/>
        </connection>
        <connection id="3" incomingRoad="1" connectingRoad="8" contactPoint="start">
            <laneLink from="1" to="1"/>
            <laneLink from="-1" to="-1"/>
        </connection>
        <connection id="4" incomingRoad="3" connectingRoad="9" contactPoint="start">
            <laneLink from="1" to="1"/>
            <laneLink from="-1" to="-1"/>
        </connection>
        <connection id="5" incomingRoad="3" connectingRoad="10" contactPoint="start">
            <laneLink from="1" to="1"/>
            <laneLink from="-1" to="-1"/>
        </connection>
    </junction>
</OpenDRIVE>
@[if crosswalk or stopline]
<!-- GeoJSON information for the crosswalks
Generated GeoJSON can be verified using: https://geojson.io
@{
}@

{
  "features": [
@[if crosswalk]
    {
      "geometry": {
        "coordinates": [
          [
@[for idx, lon_lat_z in enumerate(crosswalk_west_points_lon_lat)]@
            [
              @(lon_lat_z[0]),
              @(lon_lat_z[1]),
              @(lon_lat_z[2])
            ]@[if (idx != len(crosswalk_west_points_lon_lat)-1)],@[end if]
@[end for ]@
          ]
        ],
        "type": "Polygon"
      },
      "properties": {
          "Id": "{46c1b716-c704-427b-b57d-afe4fab608df}",
          "Type": "Crosswalk"
      },
      "type": "Feature"
    },
    {
      "geometry": {
        "coordinates": [
          [
@[for idx, lon_lat_z in enumerate(crosswalk_east_points_lon_lat)]@
            [
              @(lon_lat_z[0]),
              @(lon_lat_z[1]),
              @(lon_lat_z[2])
            ]@[if (idx != len(crosswalk_east_points_lon_lat)-1)],@[end if]
@[end for ]@
          ]
        ],
        "type": "Polygon"
      },
      "properties": {
          "Id": "{56c1b716-c704-427b-b57d-afe4fab608df}",
          "Type": "Crosswalk"
      },
      "type": "Feature"
    },
    {
      "geometry": {
        "coordinates": [
          [
@[for idx, lon_lat_z in enumerate(crosswalk_north_points_lon_lat)]@
            [
              @(lon_lat_z[0]),
              @(lon_lat_z[1]),
              @(lon_lat_z[2])
            ]@[if (idx != len(crosswalk_north_points_lon_lat)-1)],@[end if]
@[end for ]@
          ]
        ],
        "type": "Polygon"
      },
      "properties": {
          "Id": "{66c1b716-c704-427b-b57d-afe4fab608df}",
          "Type": "Crosswalk"
      },
      "type": "Feature"
    },
    {
      "geometry": {
        "coordinates": [
          [
@[for idx, lon_lat_z in enumerate(crosswalk_south_points_lon_lat)]@
            [
              @(lon_lat_z[0]),
              @(lon_lat_z[1]),
              @(lon_lat_z[2])
            ]@[if (idx != len(crosswalk_south_points_lon_lat)-1)],@[end if]
@[end for ]@
          ]
        ],
        "type": "Polygon"
      },
      "properties": {
          "Id": "{76c1b716-c704-427b-b57d-afe4fab608df}",
          "Type": "Crosswalk"
      },
      "type": "Feature"
    }@[if (stopline)],@[end if]
@[end if]@[if stopline]
    {
      "geometry": {
        "coordinates": [
@[for idx, lon_lat_z in enumerate(stopline_west_points_lon_lat)]@
          [
            @(lon_lat_z[0]),
            @(lon_lat_z[1]),
            @(lon_lat_z[2])
          ]@[if (idx != len(stopline_west_points_lon_lat)-1)],@[end if]
@[end for ]@
        ],
        "type": "LineString"
      },
      "properties": {
        "Id": "{ba11d4ae-3784-11ee-be56-0242ac120002}",
        "Type": "Stopline"
      },
      "type": "Feature"
    },
    {
      "geometry": {
        "coordinates": [
@[for idx, lon_lat_z in enumerate(stopline_east_points_lon_lat)]@
          [
            @(lon_lat_z[0]),
            @(lon_lat_z[1]),
            @(lon_lat_z[2])
          ]@[if (idx != len(stopline_east_points_lon_lat)-1)],@[end if]
@[end for ]@
        ],
        "type": "LineString"
      },
      "properties": {
        "Id": "{ba11d7ce-3784-11ee-be56-0242ac120002}",
        "Type": "Stopline"
      },
      "type": "Feature"
    }
@[end if]
  ],
  "type": "FeatureCollection"
}

-->
@[end if]
