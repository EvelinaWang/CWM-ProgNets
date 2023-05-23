/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;

header ethernet_t {
	//TODO: define the following header fields
	macAddr_t dstAddr;//macAddr_t type destination address
	macAddr_t srcAddr;//macAddr_t type source address
	bit<16> type;//16 bit etherType
}

struct metadata {
    /* empty */
}

struct headers {
	ethernet_t ethernet;//TODO: define a header ethernet of type ethernet_t
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
	packet.extract(hdr.ethernet);//TODO: define a state that extracts the ethernet header
	transition accept;//and transitions to accept
    }

}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

    action swap_mac_addresses() {
       macAddr_t tmp_mac;
       //TODO: swap source and destination MAC addresses
       tmp_mac = src;//use the defined temp variable tmp_mac
       src = dst;
       dst = tmp_mac;
       std_meta.egress_spec = std_meta.ingress_port;//TODO: send the packet back to the same port
    }
    
    
    action drop() {
	mark_to_drop(standard_metadata);
    }
    
    table src_mac_drop {
        key = {
	   hdr.ethernet.srcAddr : exact;//TODO: define an exact match key using the source MAC address
        }
        actions = {
	   swap_mac_addresses;
	   drop;
	   NoAction;//TODO: define 3 actions: swap_mac_addresses, drop, NoAction.
        }
        size = 1024;//TODO: define a table size of 1024 entries

	dafault_action = swap_mac_addresses;//TODO: define the default action to return the packet to the source
    }
    
    apply {
    	if (hdr.ethernet.isValid()){
    	src_mac_drop.apply();
    	}//TODO: Check if the Ethernet header is valid
	//if so, lookup the source MAC in the table and decide what to do
        }
    }
}
       
       
    


/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
     apply {

     }
}


/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
     packet.emit(hdr.ethernet);//TODO: emit the packet with a valid Ethernet header
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
