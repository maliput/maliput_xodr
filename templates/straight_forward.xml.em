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

def str2bool(string):
  return string.lower() in ("yes", "true", "t", "1")

def str2float(string):
  return float(string)

width = str2float(os.environ['WIDTH']) if 'WIDTH' in os.environ  else 3.0
crosswalk = str2bool(os.environ['CROSSWALK']) if 'CROSSWALK' in os.environ else False

}@
<OpenDRIVE>
    <header revMajor="1" revMinor="1" name="StraightRoad" version="1.00" date="Fri Apr 28 12:00:00 2023" north="0.0000000000000000e+00" south="0.0000000000000000e+00" east="0.0000000000000000e+00" west="0.0000000000000000e+00" maxRoad="2" maxJunc="0" maxPrg="0">
        <geoReference><![CDATA[+proj=tmerc +lat_0=37.4168716 +lon_0=-122.1030492 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +vunits=m +no_defs ]]></geoReference>
    </header>
    <road name="" length="200.0" id="1" junction="-1">
        <link>
        </link>
        <planView>
            <geometry s="0.0000000000000000e+00" x="0.0" y="0.0" hdg="0.0" length="200.0">
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
        @[if crosswalk]<objects>
            <object type="crosswalk" id="0" s="100.0" t="0.0" zOffset="0.0" orientation="none" length="2.0" width="@(width * 2)@\" hdg="0.0" pitch="0.0" roll="0.0">
                <outlines>
                    <outline id="0">
                        <cornerRoad s="99.0" t="@(width)@\" dz="0.0" height="4.0" id="0"/>
                        <cornerRoad s="99.0" t="-@(width)@\" dz="0.0" height="4.0" id="1"/>
                        <cornerRoad s="101.0" t="-@(width)@\" dz="0.0" height="4.0" id="2"/>
                        <cornerRoad s="101.0" t="@(width)@\" dz="0.0" height="4.0" id="3"/>
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
        <signals>
        </signals>
    </road>
</OpenDRIVE>
