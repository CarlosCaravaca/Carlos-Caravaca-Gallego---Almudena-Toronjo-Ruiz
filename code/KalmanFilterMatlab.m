%KALMAN FILTER USING MATLAB FUNCTION
clc; format long;

%INICIALITATION. DATA COLLECTION
%Integration interval
t = 0.02; 
X0 = zeros(6,1);
P0 = 400*eye(6);
A = [1 0 0 t 0 0; 0 1 0 0 t 0; 0 0 1 0 0 t; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1];
C = eye(6);

Solution = [];
V_IMU=[];
P_IMU=[];
MATRIX_GPS=[];

Q = eye(6);
R = eye(6);

H = dsp.KalmanFilter('StateTransitionMatrix',A, 'ControlInputPort',false,'MeasurementMatrix',C, 'ProcessNoiseCovariance',Q, 'MeasurementNoiseCovariance',R,'InitialStateEstimate',X0, 'InitialErrorCovarianceEstimate',P0);

j=1;
k=0;

for i=1:2801
    
Time_IMU = IMU_ACC(i,1); 
Yaw = IMU_GYRO(i,2);
Pitch = IMU_GYRO(i,3); 
Roll = IMU_GYRO(i,4);
Ax_IMU = IMU_ACC(i,2);
Ay_IMU = IMU_ACC(i,3);
Az_IMU = IMU_ACC(i,4);

x_GPS = GPS(j,2);
y_GPS = GPS(j,3);
z_GPS = GPS(j,4);

Vx_GPS = GPS(j,5);
Vy_GPS = GPS(j,6);
Vz_GPS = GPS(j,7);

MATRIX_GPS=[MATRIX_GPS;x_GPS y_GPS z_GPS Vx_GPS Vy_GPS Vz_GPS];

Arot_IMU = Arotation_IMU (Pitch, Roll, Yaw, Ax_IMU, Ay_IMU, Az_IMU);

Vel_IMU = quadv(@(x)descom(x,Arot_IMU),0,t); 
Pos_IMU = quadv(@(x)descom(x,Vel_IMU),0,t);

Posx_IMU=Pos_IMU(1)*100;
Posy_IMU=Pos_IMU(2)*100;

V_IMU=[V_IMU; Vel_IMU];
P_IMU=[P_IMU; Pos_IMU];

%DATA FUSION
x_FUS = x_GPS + Posx_IMU; 
y_FUS = y_GPS + Posy_IMU; 
z_FUS = z_GPS + Pos_IMU(3);

Vx_FUS = Vx_GPS + Vel_IMU(1);
Vy_FUS = Vy_GPS + Vel_IMU(2);
Vz_FUS = Vz_GPS + Vel_IMU(3);

%STATES VECTOR
Med_FUS = [x_FUS; y_FUS; z_FUS; Vx_FUS; Vy_FUS; Vz_FUS]; 
Kalman = step(H, Med_FUS);
Solution = [Solution; Kalman(1) Kalman(2) Kalman(3) Kalman(4) Kalman(5) Kalman(6)];

k=k+1;

if k==50
    k=0;
    j=j+1;
end
    
end

display(Solution)
