#!/usr/bin/env python3

import re
import random as r
import time as t

from scapy.all import *

src_MAC = "0c:37:96:5f:89:e8"
dst_MAC = "e4:5f:01:8d:c8:32"

class Traffic(Packet):
    name = "Traffic"
    fields_desc = [ StrFixedLenField("P", "P", length=1),
                    StrFixedLenField("Four", "4", length=1),
                    XByteField("version", 0x01),
                    StrFixedLenField("op", "+", length=1),
                    IntField("road_a", 0),
                    IntField("road_b", 0),
                    IntField("result_a", 0)]

eth_layer = Ether()
eth_layer.src = src_MAC
eth_layer.dst = dst_MAC
eth_layer.type = 0x1234
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
    road = road + r.randint(0,2)
    return road
    
def moving(road):
    if road >= 1:
        road = road - 1;
    return road

def num_traffic(a,b,s):
    if s == 1: #red
        a = waiting(a) 
        print('red light in road a')
        b = moving(b)
    elif s == 2:
        a = waiting(a)
        b = waiting(b)
    else:
        print('green light in road a')
        a = moving(a) 
        b = waiting(b)
    return a ,b

def main():
 
    iface = "enx0c37965f89e8"
    road_a, road_b, result_a = 4,0,0
    
    for i in range(0,15):
    
        road_a, road_b = num_traffic(road_a, road_b, result_a)   
        
        try:
            pkt = eth_layer/Traffic(op="+", 
                                    road_a=road_a, 
                                    road_b=road_b,
                                    result_a=result_a)	
            pkt = pkt/' '
            #print(pkt.summary)
            print('in road_a = ',road_a, 'road_b = ',road_b, 'a =' ,result_a)
            
            resp = srp1(pkt, iface=iface,timeout=5, verbose=False)
            #print(resp)
            traffic = resp[Traffic] 
            print('out road_a = ',traffic.road_a, 'road_b = ',traffic.road_b, 'a =' ,traffic.result_a)
            t.sleep(2)
            result_a = traffic.result_a
            
	#pkt.show()
            #resp = srp1(pkt, iface=iface,timeout=10,verbose=False)
            #print(resp)
            #if resp:
                #traffic=resp[Traffic]
                #if traffic:
            	    #print(Traffic.road_a, Traffic.road_b, Traffic.result_a)
            	    #break
                #else:
                    #print("cannot find header in the packet")
                    #break
            
        except Exception as error:
            print(error)
            
if __name__ == '__main__':
    main()

