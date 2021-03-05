function M = Arotation_IMU (Pitch,Roll,Yaw,Acel_x,Acel_y,Acel_z)

Rz_yaw = [cos(Yaw) -sin(Yaw) 0; sin(Yaw) cos(Yaw) 0; 0 0 1];
Ry_roll = [cos(Roll) 0 sin(Roll); 0 1 0; -sin(Roll) 0 cos(Roll)];
Rx_pitch = [1 0 0; 0 cos(Pitch) -sin(Pitch); 0 sin(Pitch) cos(Pitch)];

M = Rz_yaw*Ry_roll*Rx_pitch;
M = M*[Acel_x; Acel_y; Acel_z];

end