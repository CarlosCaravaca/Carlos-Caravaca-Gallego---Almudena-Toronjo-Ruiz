with Ada.Numerics.Real_Arrays;
use  Ada.Numerics.Real_Arrays;
generic
	type Real is digits <>;  -- used to define any floating-point type
	N : Positive; -- N represents the dimension of the state
	M : positive; -- M represents the number of measurements
package generalKalmanFilter is
	type State is Real_vector (1..N);
	type stateMatrix is Real_Matrix (1..N, 1..M);
	type Measurements is Real_Matrix (1..N, 1..M);
	procedure defineStateMatrix (F : in stateMatrix);
	procedure defineNoise (Q : in stateMatrix);
	procedure defineMeasurements (h : in Measurements);
	procedure defineMeasurementsNoise (r : in Real);
	procedure predictionStep (X : in out State;
							  P : in out stateMatrix);
	procedure updateStep (z : in Real;
						  X : in out State;
						  P : in out stateMatrix;
						  R : out Real);
end generalKalmanFilter;