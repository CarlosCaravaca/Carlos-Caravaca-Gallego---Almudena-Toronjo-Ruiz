import serial
import time
class serialInterface():

	tty = None
	baud = None
	serial = None

	def __init__(self, tty, baud = 9600):
		self.tty = tty
		self.baud = baud
		self.serial = serial.Serial(self.tty, self.baud)

	def read(self):
		in_bytes = self.serial.inWaiting()
		time.sleep(1)
		if in_bytes > 0:
			return self.serial.read(in_bytes)
		else:
			return ""

interface = serialInterface('/dev/ttyUSB1',4800)
while True:
	print(interface.read())