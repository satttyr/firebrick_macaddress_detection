'''
rawSocket = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(0x0003))
rawSocket.bind(("wlan1", 0x0003))
wireless_list = set()
device_list = set()
prev_time = datetime.datetime.now()
#buffer = [65565]
while True :
  pkt = rawSocket.recvfrom(64)[0] 
  if pkt[18] == "\x80" :
        if pkt[28:34] not in wireless_list  and ord(pkt[55]) > 0:
            wireless_list.add(pkt[28:34])
            mac1 = pkt[28:34].encode('hex').upper()
            print "AP MAC: %s       SSID: %s " % ((':'.join(mac1[i]+mac1[i+1] for i in range(0, len(mac1),2))), pkt[56:56 +ord(pkt[55])])           
    
  if pkt[18] == "\xd4":
    if pkt[22:28] not in wireless_list and pkt[22:28] not in device_list:
        device_list.add(pkt[22:28])
        mac2 = pkt[22:28].encode('hex').upper()
        last_time = time.strftime("%H:%M:%S")
        print " %s device MAC : %s " % (last_time, (':'.join(mac2[i]+mac2[i+1] for i in range(0, len(mac2),2)))) 
 '''

import datetime
import pygame
import pygame.camera
import pyshark
wireless_list = dict()
device_list = dict()

pygame.camera.init()
camera_list = pygame.camera.list_cameras()
if (len(camera_list) == 0):
    print "No video devices detected"
else:
    cam = pygame.camera.Camera("/dev/video0", (640,480))
    cam.start()
    capture = pyshark.LiveCapture(interface='wlan1')
    while True :
        for pkt in capture.sniff_continuously(packet_count=1000):
            if hasattr(pkt, 'wlan'):
                if pkt.wlan.fc == "0x8000" and (pkt.wlan.addr not in wireless_list or (datetime.datetime.now()- wireless_list[pkt.wlan.addr]) > datetime.timedelta(seconds=30) ):
                    wireless_list.update({pkt.wlan.addr : datetime.datetime.now()})
                    print "Wirelless device MAC: %s       Name: %s" % (pkt.wlan.addr, pkt.wlan._all_fields["wlan.bssid"].showname)           
                if pkt.wlan.da != "ff:ff:ff:ff:ff:ff" and pkt.wlan.addr not in wireless_list and (pkt.wlan.addr not in device_list or (datetime.datetime.now()- device_list[pkt.wlan.addr]) > datetime.timedelta(seconds=30)):
                    capture_time = datetime.datetime.now()
                    image_name = pkt.wlan.addr + "_" +unicode(capture_time) + ".jpg"
                    device_list.update({pkt.wlan.addr : capture_time})
                    print " device MAC : %s " % (pkt.wlan.addr) 
                    img = cam.get_image()
                    pygame.image.save(img, image_name)