import utm
import csv
import numpy as np

#Define function to convert latitude and longitude to local XYZ coordinates
def latlon_to_xyz(latitude,longitude):
	#Latitude in format DDMM.MMMMM
	#Longitude in format DDDMM.MMMMM
	lat_sign = 1 if latitude[1] == "N" else -1
	lon_sign = 1 if longitude[1] == "E" else -1
	lat_deg_min    = [int(latitude[0][:2]),float(latitude[0][2:])]
	lon_deg_min    = [int(longitude[0][:3]),float(longitude[0][3:])]
	lat  = ((float(lat_deg_min[0])
	            + float(lat_deg_min[1])/60.0)*lat_sign)
	lon = ((float(lon_deg_min[0])
	            + float(lon_deg_min[1])/60.0)*lon_sign)
	return (utm.from_latlon(lat, lon)[0], utm.from_latlon(lat, lon)[1])

state = {} #Initialize state as an empty python dictionary
GPS_rate = 1 #Establish GPS_rate in Hz
with open('GPS.txt', 'r') as f:
	sentences = f.readlines()
	for line in sentences:
		#Retrieve position and velocity from GGA sentences
		if line[3:6] == 'GGA':
			gga  = line.replace("\r\n","").split(",")
			timestamp = float(gga[1])
			lat = (str(gga[2]),str(gga[3]))
			lon = (str(gga[4]),str(gga[5]))
			x, y = latlon_to_xyz(lat,lon)
			z = float(gga[9])
			position = [x,y,z]
			#Try-except to avoid errors when initialising the system
			try:
				velocity = [(x - y)/GPS_rate for x, y in
				                zip(position, state[timestamp-GPS_rate][0:3])]
			except:
				velocity = [0,0,0]
			state[timestamp] = position + velocity

#Routine to correct velocity using RMC sentences
with open('GPS.txt', 'r') as f:
	sentences = f.readlines()
	for line in sentences:
		if line[3:6] == 'RMC':
			rmc = line.replace("\r\n","").split(",")
			speed_rmc = float(rmc[7])*0.51444 #Knots to m/s
			timestamp = float(rmc[1])
			velocity_gga = np.array(state[timestamp][3:6])
			speed_gga = np.linalg.norm(velocity_gga)
			correction_factor = speed_rmc/speed_gga
			state[timestamp][3:6] = [component * correction_factor
			                           for component in velocity_gga]

#Convert dictionary to list to it can be written in CSV format
state_list = []
for key in state:
	state[key].insert(0,key)
	state_list.append(state[key])

#Output results to CSV format
with open("gps_out.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(state_list)