#!/usr/bin/env python3

import re

from scapy.all import *

class Traffic(Packet):
    name = "car number"
    fields_desc = [ StrFixedLenField("P", "P", length=1),
                    StrFixedLenField("Four", "4", length=1),
                    XByteField("version", 0x01),
                    StrFixedLenField("op", "+", length=1),
                    IntField("road_a", 0),
                    IntField("road_b", 0),
                    IntField("result_a", 1)]

bind_layers(Ether, Traffic, type=0x1234)

class Token:
    def __init__(self,type,value = None):
        self.type = type
        self.value = value

def get_if():
    ifs=get_if_list()
    
    iface= "enx0c37965f89e8" 
    return iface

def waiting(road):
    while True:
        road = road + 1
        delay(0.5*randint(1, 10))

def moving(road):
    while road >= 1:
        road = road - 1;
        delay(1)
    return road

def num_traffic(a,b,s):
    if s == 1:
        a = waiting(a) 
        b = moving(b)
    elif s == 2:
        a = waiting(a)
        b = waiting(b)
    else:
        a = moving(a) 
        b = waiting(b)
    return a ,b
    
def main():
    road_a = 0
    road_b = 0

    iface = "enx0c37965f89e8"

    while True:
        road_a, road_b = num_traffic(road_a, road_b, result_a)
        
	pkt = Ether(dst='00:04:00:00:00:00', type=0x1234) / Traffic(op="+", road_a, road_b, result_a)

	pkt = pkt/' '

	#pkt.show()
	resp = srp1(pkt, iface=iface, timeout=5, verbose=False)
	if resp:
	    Traffic=resp[Traffic]
	    
            if Traffic:
            
		print(Traffic.road_a, Traffic.road_b, Traffic.result_a)
	    else:
		print("cannot find header in the packet")
        delay(1)

if __name__ == '__main__':
    main()

