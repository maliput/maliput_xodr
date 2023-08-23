#!/bin/bash

# Updates resources with the latest version of the XODR schema templates.

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Generates straight_forward resources
WIDTH=3 CROSSWALK=True empy3 ${script_dir}/../templates/straight_forward.xml.em > ${script_dir}/../resources/straight_forward/straight_forward_3m_width_crosswalk.xodr
WIDTH=3.5 CROSSWALK=True empy3 ${script_dir}/../templates/straight_forward.xml.em > ${script_dir}/../resources/straight_forward/straight_forward_3_5m_width_crosswalk.xodr
WIDTH=4 CROSSWALK=True empy3 ${script_dir}/../templates/straight_forward.xml.em > ${script_dir}/../resources/straight_forward/straight_forward_4m_width_crosswalk.xodr

WIDTH=3 CROSSWALK=False empy3 ${script_dir}/../templates/straight_forward.xml.em > ${script_dir}/../resources/straight_forward/straight_forward_3m_width.xodr
WIDTH=3.5 CROSSWALK=False empy3 ${script_dir}/../templates/straight_forward.xml.em > ${script_dir}/../resources/straight_forward/straight_forward_3_5m_width.xodr
WIDTH=4 CROSSWALK=False empy3 ${script_dir}/../templates/straight_forward.xml.em > ${script_dir}/../resources/straight_forward/straight_forward_4m_width.xodr

# Generates intersection resources
WIDTH=3 CROSSWALK=True CROSSWALK_LENGTH=2 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_3m_width_crosswalk.xodr
WIDTH=3.5 CROSSWALK=True CROSSWALK_LENGTH=2 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_3_5m_width_crosswalk.xodr
WIDTH=4 CROSSWALK=True CROSSWALK_LENGTH=2 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_4m_width_crosswalk.xodr

WIDTH=3 CROSSWALK=False CROSSWALK_LENGTH=2 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_3m_width.xodr
WIDTH=3.5 CROSSWALK=False CROSSWALK_LENGTH=2 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_3_5m_width.xodr
WIDTH=4 CROSSWALK=False CROSSWALK_LENGTH=2 empy3 ${script_dir}/../templates/intersection.xml.em > ${script_dir}/../resources/intersection/intersection_4m_width.xodr

# Generates curved_road resources
empy3 ${script_dir}/../templates/curved_road.xml.em > ${script_dir}/../resources/curved_road/curved_road_default.xodr
