

##### Robot Arm Torque Calculator #####


## about ##

This app draws a 6DOF serial manipulator robot arm in 2D and calculates the linear and torque forces on each joint.
The robot's mass and dimensions are set in the robotArm constructor. 

Written 2017-09-05 in Processsing 3.3.5 by Dan Royer (dan@marginallyclever.com) 

Default unit of measurement is meters, kilograms, celcius, radians.


## controls ##

Spacebar toggles the clock pause.
When the mouse cursor is near a planar joint that joint will become highlighted.
Click and hold the left mouse button to make a highlighted joint into a selected joint.
Q/E will rotate a selected joint if the clock is not paused.
1 will toggle display of torque at each joint.
2 will toggle display of angle at each joint.


## output ##

Bottom left of screen shows total seconds of unpaused clock time.  red is paused.  green is unpaused.
Arm is on the top of the screen becase Y=0 is top of Processing window and Y+ is downwards.
Robot arm linkages are in dark blue.
Robot linear forces (gravity) are in green.
Most robot joints are in yellow.
Highlighted robot joints have an orange box around them.
Selected joints are red and have a line leading to the mouse cursor.
Each robot joint displays the current angle (?) in degrees and the torque force (T) in Newtons.
