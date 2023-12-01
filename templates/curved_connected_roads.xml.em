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
width = str2float(os.environ['WIDTH']) if 'WIDTH' in os.environ  else 3.5
# Radius of curvature
radius = str2float(os.environ['RADIUS']) if 'RADIUS' in os.environ else 12.0
# Length of straight exit road
exit_road_length = str2float(os.environ['EXIT_ROAD_LENGTH']) if 'EXIT_ROAD_LENGTH' in os.environ else 300.0
# Length of the middle connected road
middle_road_length = str2float(os.environ['MIDDLE_ROAD_LENGTH']) if 'MIDDLE_ROAD_LENGTH' in os.environ else 300.0

# Map
#
#         xxxxxxxxxxxxxx<- Road 2 ->xxxxxxxxxxxxxx
#       xxxx                                    xxxx
#     xxx                                          xxx
#    xx                                              xx
#   xx                                                xx
#  xx                                                  xx
#  xx <--------------> X radius                        xx
#  xx                                                  xx
#  xx                                                  xx
#  xx                                                  xx
#
# Road 1                                              Road 3
#
# Considerations:
#  * Roads are not connected
#

# Road 1 (South - East)
road_1_start = [0. + x_offset, 0. + y_offset]
road_1_end_straight = [road_1_start[0], road_1_start[1] + exit_road_length]

road_1_radius = radius + width
road_1_curvature = 1./road_1_radius
road_1_curved_length = road_1_radius * m.pi / 2. # 90 degrees of curvature
road_1_length = exit_road_length + road_1_curved_length

road_1_final_end = [road_1_start[0] + road_1_radius, road_1_start[1] + exit_road_length + road_1_radius]

# Road 2 (West - East)
road_2_start = [road_1_final_end[0], road_1_final_end[1]]
road_2_length = middle_road_length
road_2_end = [road_2_start[0] + road_2_length, road_2_start[1]]

# Road 3 (West - South)
road_3_start = [road_2_end[0], road_2_end[1]]
road_3_radius = road_1_radius
road_3_curvature = 1./road_3_radius
road_3_curved_length = road_3_radius * m.pi / 2. # 90 degrees of curvature
road_3_length = exit_road_length + road_3_curved_length
road_3_end_curved = [road_3_start[0] + road_3_radius, road_3_start[1] - road_3_radius]
road_3_final_end = [road_3_end_curved[0], road_3_end_curved[1] - exit_road_length]


}@
<!--
 Map generated using https://github.com/maliput/maliput_xodr.
 Generated using the following parameters:
  - WIDTH: @(width)@ 
    - Indicates the width of the lane
  - RADIUS: @(radius)@ 
    - Indicates the radius of the curved section
  - EXIT_ROAD_LENGTH: @(exit_road_length)@ 
    - Indicates the length of the straight section
  - MIDDLE_ROAD_LENGTH: @(middle_road_length)@ 
    - Indicates the length of the middle road section
  - OFFSET_X: @(x_offset)@ 
    - Indicates the offset in the x axis of the openDRIVE map
  - OFFSET_Y: @(y_offset)@ 
    - Indicates the offset in the y axis of the openDRIVE map
-->
<OpenDRIVE>
    <header revMajor="1" revMinor="1" name="Connected Curved Roads" version="1.00" date="Fri Oct 27 12:00:00 2023" north="0.0000000000000000e+00" south="0.0000000000000000e+00" east="0.0000000000000000e+00" west="0.0000000000000000e+00" maxRoad="2" maxJunc="0" maxPrg="0">
        <geoReference><![CDATA[+proj=tmerc +lat_0=@(LAT_0)@  +lon_0=@(LON_0)@  +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +vunits=m +no_defs ]]></geoReference>
    </header>
    <road name="Road 1" length="@(road_1_length)@\" id="1" junction="-1">
        <link>
            <successor elementType="road" elementId="2" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_1_start[0])@\" y="@(road_1_start[1])@\" hdg="@(m.pi/2.)@\" length="@(exit_road_length)@\">
                <line/>
            </geometry>
            <geometry s="@(exit_road_length)@\" x="@(road_1_end_straight[0])@\" y="@(road_1_end_straight[1])@\" hdg="@(m.pi/2.)@\" length="@(road_1_curved_length)@\">
                <arc curvature="@(-road_1_curvature)@\"/>
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
        </lanes>
    </road>
    <road name="Road 2" length="@(road_2_length)@\" id="2" junction="-1">
        <link>
            <predecessor elementType="road" elementId="1" contactPoint="end"/>
            <successor elementType="road" elementId="3" contactPoint="start"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_2_start[0])@\" y="@(road_2_start[1])@\" hdg="0.0" length="@(road_2_length)@\">
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
        </lanes>
    </road>
    <road name="Road 3" length="@(road_3_length)@\" id="3" junction="-1">
        <link>
            <predecessor elementType="road" elementId="2" contactPoint="end"/>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="@(road_3_start[0])@\" y="@(road_3_start[1])@\" hdg="0.0" length="@(road_3_curved_length)@\">
                <arc curvature="@(-road_3_curvature)@\"/>
            </geometry>
            <geometry s="@(road_3_curved_length)@\" x="@(road_3_end_curved[0])@\" y="@(road_3_end_curved[1])@\" hdg="@(-m.pi/2.)@\" length="@(exit_road_length)@\">
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
