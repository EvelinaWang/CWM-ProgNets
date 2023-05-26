
/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> p4wallAddr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

const bit<16> P4wall_ETYPE = 0x1234;
const bit<8>  P4wall_P     = 0x50;   // 'P'
const bit<8>  P4wall_4     = 0x34;   // '4'
const bit<8>  P4wall_VER   = 0x01;   // v0.1

header p4wall_t {
    bit<8>    p;
    bit<8>    four;
    bit<8>    ver;
    bit<8>    op;
    bit<32>   road_a;
    bit<32>   road_b;
    bit<32>   result_a;
    p4wallAddr_t srcAddr;
    p4wallAddr_t dstAddr;
}

struct metadata {
    /* empty */
}

struct headers {
    ethernet_t   ethernet;
    p4wall_t       p4wall;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            P4wall_ETYPE : check_p4wall;
            default      : accept;
        }
    }

    state check_p4wall {
        transition select(packet.lookahead<p4wall_t>().p,
        packet.lookahead<p4wall_t>().four,
        packet.lookahead<p4wall_t>().ver) {
            (P4wall_P, P4wall_4, P4wall_VER) : parse_p4wall;
            default                          : accept;
        }
       
    }

    state parse_p4wall {
        packet.extract(hdr.p4wall);
        transition accept;
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

    action send_back(bit<32> result_a) {
        hdr.p4wall.result_a = result_a;
        bit<48> temp = hdr.ethernet.srcAddr;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = temp;
        standard_metadata.egress_spec = standard_metadata.ingress_port;
    }
    
    action operation_green_to_red() {
        send_back(1);
        /* TODO call send_back with result_a to be red */
    }

    action operation_red_to_green() {
        send_back(3);
       /* TODO call send_back with result_a to be green */
    }
    
    table operation {
        key = {
            hdr.p4wall.road_a : exact;
            hdr.p4wall.road_b : exact;
        }
        actions = {
            operation_green_to_red;
            operation_red_to_green;
        }
        const default_action = operation_green_to_red();
        
        const entries = {
             (0,1): operation_green_to_red();
             (1,0): operation_red_to_green();
        }
    }
    apply {
        if (hdr.p4wall.isValid()) {
            operation.apply();
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
     apply { }
    }


/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.p4wall);/* TODO: add deparser logic */
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
