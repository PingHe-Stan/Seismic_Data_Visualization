#!/bin/bash
#
# This script is to use the compiled Moho data from PSDEPTH to constrain Moho Lateral Variation beneath Nepal Himalaya Orogen.
#
# Date: 2016-11-1 Author: Stan He

gmtset MAP_GRID_PEN_PRIMARY=thinnest,. MAP_FRAME_TYPE=fancy

# Rawdata
tectoinfodir=/home/hep/Nepal/RF_GMT/Data/TectonicSetting
profinfodir=/home/hep/Nepal/RF_GMT/Data/AlongProfile
allinfodir=/home/hep/Nepal/RF_GMT/Data/AllRFProcess
mohodatadir=/home/hep/Nepal/RF_GMT/6_Topo_Moho_3DPersp/Data

profileinfo=${profinfodir}/Line_AA
YL="${tectoinfodir}/Processed_Stainfo_YL"
XF="${tectoinfodir}/Processed_Stainfo_XF"
pspierf=${allinfodir}/PROCESSED_PSPIER.STX
nepaltopogrd=${tectoinfodir}/China.grd
mohodata=${mohodatadir}/Moho.compiled

profileinfo1=${profinfodir}/Line_AA
profileinfo2=${profinfodir}/Line_BB
profileinfo3=${profinfodir}/Line_CC
profileinfo4=${profinfodir}/Line_DD
profileinfo5=${profinfodir}/Line_EE
profileinfo6=${profinfodir}/Line_FF
profileinfo7=${profinfodir}/Line_GG

TECT="${tectoinfodir}/tec-china.dat"

# Name of Generated Intermediate file for plotting
mohotopogrd=moho.grd
RAY3D=3drays


# Abbreviation
BEG="-K -P"
ADD="-K -O -P"
END="-O -P"
REG="-R82/90/26/31"
#REG="-R65/135/15/55"
CPTOPT1="-C${tectoinfodir}/Nepal_grey.cpt"
CPTOPT1="-C${tectoinfodir}/GMT_globe.cpt"
REG3D=${REG}/-85000/6500

RAYPEN="-W0.1,grey55,-"
LINEPEN="-W1.5p,khaki1,solid"


# PS file name
ps=my_3d_moho_topo.ps


# Step 1: create Moho grid. 
# GMT progs: surface Moho grid will be created constrained by Moho xyz data
# Limit control -Ll lowerlimit -Lu Upperlimit self-defined value or d(min or max value) in xyz file
# -T Tension Indicator, 0.25 for smoothing variation 0.75 for topography variation
awk '{print $1,$2,$3*-1000}' $mohodata| surface -G$mohotopogrd -I0.2/0.2 -R82/90/26/31 -T0.2 -Lld -Lud -s
grdgradient moho.grd -A270 -Gmoho.grad -Ne0.6

# Create CPT file using Moho grid, -C color model for generating CPT file
grd2cpt moho.grd -Cgray -E25 > mygrd.cpt
grd2cpt moho.grd -Cno_green -E50 > mygrd1.cpt

# Preview of grd file, info can be viewed using grdinfo

#grdimage moho.grd -Cmygrd.cpt -R -JM15c -K -B1/1 > $ps
# Draw Color Bar: psscale: -D location and size of Color bar, -E for- and back- ending will be plotted using small triangle
#psscale -D16c/2c/5c/0.5c -I -E -Ba20f10:"Depth (km)": -Cmygrd.cpt -K -O >> $ps


# Step 2: create 3D ray lines for illustration 
awk '{print $3,$2}' $pspierf |grdtrack -G$nepaltopogrd > station.ele
awk '{print $6,$5}' $pspierf |grdtrack -G$mohotopogrd > ps.depth

paste -d" " station.ele ps.depth | awk '{printf ">\n%5.5f %5.5f %5.5f\n%5.5f %5.5f %5.5f\n",$1,$2,$3,$4,$5,$6}' >  ${RAY3D}

rm station.ele ps.depth

point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`
startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`


#grdview China_20m.grd ${REG}/-90000/7000 -JM15c  -JZ12c $CPTOPT1 -Qs+m -p135/30 -IChina_20m.grad -Ba20f5g10/a10f5g5WSne $BEG > $ps

grdimage moho.grd -Cmygrd1.cpt $REG -JM14c -p135/30 $BEG > $ps
psscale -D14.5c/10c/3c/0.3c -I -E -Ba20000f10000 -Cmygrd1.cpt -K -O >> $ps
cat $profileinfo1 | psxy $REG -JM14c -W1p,black,. -p $ADD >> $ps
echo "88.3 27 M B T" | pstext $REG -JM14c -F+f7p,Helvetica-Bold,gray10+jLB -p $ADD >> $ps
cat $profileinfo2 | psxy $REG -JM14c -W1p,black,. -p $ADD >> $ps
echo "88.2 28.3 S T D" | pstext $REG -JM14c -F+f7p,Helvetica-Bold,gray10+jLB -p $ADD >> $ps
cat $profileinfo3 | psxy $REG -JM14c -W1p,black,. -p $ADD >> $ps
echo "88.3 29.15 Y Z S" | pstext $REG -JM14c -F+f7p,Helvetica-Bold,gray10+jLB -p $ADD >> $ps
cat $profileinfo4 | psxy $REG -JM14c -W1p,black,. -p $ADD >> $ps
echo "83.4 27.3 W N H" | pstext $REG -JM14c -F+f7p,Helvetica-Bold,gray10+jRB -p $ADD >> $ps
cat $profileinfo5 | psxy $REG -JM14c -W1p,black,. -p $ADD >> $ps
echo "84.6 27 C N H" | pstext $REG -JM14c -F+f7p,Helvetica-Bold,gray10+jRB -p $ADD >> $ps
cat $profileinfo6 | psxy $REG -JM14c -W1p,black,. -p $ADD >> $ps
echo "85.0 26.5 N H T" | pstext $REG -JM14c -F+f7p,Helvetica-Bold,gray10+jRB -p $ADD >> $ps
cat $profileinfo7 | psxy $REG -JM14c -W1p,black,. -p $ADD >> $ps
echo "86.5 26.3 E N H" | pstext $REG -JM14c -F+f7p,Helvetica-Bold,gray10+jRB -p $ADD >> $ps

psxy $TECT -R -J -W1.3,gray25,- -p $ADD>> $ps

grdview ${mohotopogrd} $REG3D -JM14c  -JZ12c -Cmygrd.cpt -Imoho.grad -Qs+m -Ba2f1g1/a1f0.5g0.5/a20000f5000g10000:"Topography (m)":SEwnZ -p135/30  $ADD >> $ps
#grdview ${mohotopogrd} $REG3D -JM14c  -JZ12c -Cmygrd.cpt -Imoho.grad -Qs+m -N-85000+ggray -p135/30  $BEG > $ps
psxyz $REG3D -JM15c  -JZ12c -p135/30 $RAYPEN $ADD $RAY3D >> $ps

grdview ${nepaltopogrd} $REG3D -JM14c  -JZ12c $CPTOPT1 -Qs+m -p135/30 -I${tectoinfodir}/China.grad $ADD >> $ps
#grdview ${nepaltopogrd} $REG3D -JM14c  -JZ12c $CPTOPT1 -Qs+m -p135/30 -I${tectoinfodir}/China.grad -Ba2f1/a1f0.5/a20000f5000g10000:"Topography (m)":SEZ $ADD >> $ps


project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$nepaltopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps


echo "84.649 28.131" |grdtrack -G$nepaltopogrd | psxyz $REG3D -J -JZ -p -Sa0.2i -Gred $ADD >> $ps  
echo "84.74 28.23 2000 April 2015 Gorhka earthquake" | pstext $REG3D -J -JZ -p -F+f8,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps


profileinfo=${profinfodir}/Line_FF
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$nepaltopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps


awk '{print $3" "$2" "$4}' $YL |psxyz $REG3D -J -JZ -p -Sd0.05i -Gkhaki3 $ADD >> $ps
awk '{print $3" "$2" "$4}' $XF |psxyz $REG3D -J -JZ -p -St0.05i -Gkhaki3 $ADD >> $ps

#| awk '$0~!/^>/{print $0}'
# XY to XYZ coordinate for 3D overlapping visual effect
#echo "84.8 26.7 N H T" | pstext ${REG}/-7500/7000 -J -JZ -F+f7p,Helvetica-Bold,gray10+jRB $ADD >> $ps

#| psxyz ${REG}/-7500/7000 -J -JZ -W1p,black,. $ADD >> $ps
rm *.cpt

evince $ps
