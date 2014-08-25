import datetime
import pygame
import pygame.camera
import pyshark
wirelessList = dict()
deviceList = dict()
interfaceName = 'wlan1'
cameraName = '/dev/video0'

def checkIfWireless(packet):
    if packet.wlan.fc == "0x8000" :
        if (packet.wlan.addr not in wirelessList or (datetime.datetime.now() - wirelessList[packet.wlan.addr]) > datetime.timedelta(minutes=1)):
            print "Wirelless access point MAC: %s       Name: %s" % (packet.wlan.addr, packet.wlan._all_fields["wlan.bssid"].showname) 
        wirelessList.update({packet.wlan.addr : datetime.datetime.now()}) 

def checkIfNewDevice(packet):
    if packet is not None and packet.wlan is not None and hasattr(packet.wlan,'da') and packet.wlan.da != "ff:ff:ff:ff:ff:ff" and packet.wlan.addr is not None and packet.wlan.addr not in wirelessList :
        captureTime = datetime.datetime.now()
        if packet.wlan.addr not in deviceList or (datetime.datetime.now() - deviceList[packet.wlan.addr]) > datetime.timedelta(minutes=1):
                imageName = packet.wlan.addr + "_" + unicode(captureTime) + ".jpg"
                print " device MAC : %s " % (packet.wlan.addr) 
                img = cam.get_image()
                pygame.image.save(img, imageName)
        deviceList.update({packet.wlan.addr : captureTime})
                    
pygame.camera.init()
cameraList = pygame.camera.list_cameras()
if (len(cameraList) == 0):
    print "No video devices detected"
else:
    cam = pygame.camera.Camera(cameraName, (640, 480))
    cam.start()
    capture = pyshark.LiveCapture(interface = interfaceName)
    while True :
        for pkt in capture.sniff_continuously(packet_count=1000):
            if hasattr(pkt, 'wlan'):
                checkIfWireless(pkt)
                checkIfNewDevice(pkt)                        
                
