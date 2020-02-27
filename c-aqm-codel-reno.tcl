#Create a simulator object
set ns [new Simulator]

set opt(nflow) 27
set opt(TcpSink) 14

set retransmit [open tcprtx.q w]

################################
####    Network Topology    ####
################################

 for {set flow 0} {$flow <= $opt(nflow) } {incr flow}  {

set node_(r1) [$ns node]
set node_(r2) [$ns node]
set n($flow) [$ns node]
}

 for {set flow 0} {$flow <= $opt(nflow) } {incr flow 2}  {
$ns duplex-link $n($flow) $node_(r1) 15Mb 15ms DropTail
$ns duplex-link $node_(r1) $n($flow) 15Mb 15ms DropTail
$ns queue-limit $n($flow) $node_(r1) 1000
$ns queue-limit $node_(r1) $n($flow) 1000
}

  for {set flow 1} {$flow <= $opt(nflow) } {incr flow 2}  {
$ns duplex-link $node_(r2) $n($flow) 15Mb 15ms DropTail
$ns duplex-link $n($flow) $node_(r2) 15Mb 15ms DropTail
$ns queue-limit $node_(r2) $n($flow) 1000
$ns queue-limit $n($flow) $node_(r2) 1000
}


$ns duplex-link $node_(r1) $node_(r2) 3Mb 0ms CoDel	 
$ns duplex-link $node_(r2) $node_(r1) 3Mb 0ms CoDel 
$ns queue-limit $node_(r1) $node_(r2) 1000
$ns queue-limit $node_(r2) $node_(r1) 1000
 
################################
####    Configuring TCP     ####
################################

Agent/TCP set precisionReduce_ false ;   # default changed on 2006/1/24.
Agent/TCP set rtxcur_init_ 6.0 ;      # Default changed on 2006/01/21
Agent/TCP set updated_rttvar_ false ;  # Variable added on 2006/1/21
Agent/TCP set minrto_ 1
Agent/TCP/Newreno set newreno_changes1_ 0
Agent/TCP/Newreno set partial_window_deflation_ 0  
for {set id 1} {$id <= $opt(TcpSink) } {incr id}  {
set tcp($id) [new Agent/TCP/Reno]
$tcp($id) set fid_ 1
$tcp($id) set class_ 1
#$tcp($id) set window_ 10000
$tcp($id) set packetSize_ 1420
$tcp($id) attach $retransmit
$tcp($id) tracevar nrexmitpack_
$tcp($id) tracevar ndatabytes_
$tcp($id) tracevar cwnd_

set sink($id) [new Agent/TCPSink]
$sink($id) set class_ 1
}

set id 1

for {set flow 1} {$flow <= $opt(nflow) } {incr flow 2}  {

$ns attach-agent $n([expr $flow-1]) $tcp($id)
$ns attach-agent $n($flow) $sink($id)
$ns connect $tcp($id) $sink($id)
incr id
}

################################
####   App 01: FTP Source   ####
################################

for {set id 1} {$id <= $opt(TcpSink) } {incr id}  {
set ftp($id) [new Application/FTP]
set ftp($id) [$tcp($id) attach-source FTP]
}

# Tracing a queue
set codelq [[$ns link $node_(r1) $node_(r2)] queue]
set tchan_ [open resultall.q w]
$codelq trace curq_
$codelq trace d_exp_
$codelq trace linkuntilization_
$codelq trace ratedrop_ 
$codelq trace enqc_
$codelq trace oq_
$codelq trace qdiff_ 
$codelq attach $tchan_


set flowstart 0
for {set id 1} {$id <= $opt(TcpSink) } {incr id}  {
$ns at $flowstart "$ftp($id) start"
set flowstart [expr $flowstart+0.5]
}

$ns at 100 "finish" 

# Define 'finish' procedure (include post-simulation processes)
proc finish {} {
    global tchan_
	
    set awkCode1 {
	{
	    if ($1 == "c" && NF>2) {
		print $2, $3 >> "temp.codelc";
		set end $2
	    }
	    else if ($1 == "d" && NF>2) {
	    print $2, $3 >> "temp.codeld";
		}
		else if ($1 == "q" && NF>2) {
	    print $2, $3 >> "temp.codelq";
		}
		else if ($1 == "e" && NF>2) {
	    print $2, $3 >> "temp.codele";
		}
		else if ($1 == "o" && NF>2) {
	    print $2, $3 >> "temp.codelo";
		}
		else if ($1 == "r" && NF>2) {
	    print $2, $3 >> "temp.codelr";
		}
		else if ($1 == "l" && NF>2) {
	    print $2, $3 >> "temp.codell";
		}
	}
    }
    if { [info exists tchan_] } {
	close $tchan_
    }
global retransmit
set awkCode2 {
	{
	    if ($2 == 2 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow01";
	    	}
	   	else if ($2 == 8 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow02";
		}
		else if ($2 == 14 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow03";
		}
	       else if ($2 == 20 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow04";
	    	}
	   	else if ($2 == 26 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow05";
		}
		else if ($2 == 32 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow06";
		}
		else if ($2 == 38 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow07";
		}
	       else if ($2 == 44 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow08";
	    	}
	   	else if ($2 == 50 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow09";
		}
		else if ($2 == 56 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow10";
		}
		else if ($2 == 62 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow11";
		}
	       else if ($2 == 68 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow12";
	    	}
	   	else if ($2 == 74 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow13";
		}
		else if ($2 == 80 && $6== "ndatabytes_" && NF>2) {
		print $1, $7 >> "FtpFlow14";
		}


		else if ($2 == 2 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow01";
	    	}
	   	 else if ($2 == 8 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow02";
		}
		else if ($2 == 14 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow03";
		}
		else if ($2 == 20 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow04";
	    	}
	   	 else if ($2 == 26 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow05";
		}
		else if ($2 == 32 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow06";
		}
		else if ($2 == 38 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow07";
		}
		else if ($2 == 44 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow08";
	    	}
	   	 else if ($2 == 50 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow09";
		}
		else if ($2 == 56 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow10";
		}
		else if ($2 == 62 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow11";
		}
		else if ($2 == 68 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow12";
	    	}
	   	 else if ($2 == 74 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow13";
		}
		else if ($2 == 80 && $6== "nrexmitpack_" && NF>2) {
		print $1, $7 >> "RtxFlow14";
		}
		else if ($2 == 2 && $6== "cwnd_" && NF>2) {
		print $1, $7 >> "cwndreno";
		}
	}
    }

if { [info exists retransmit] } {
	close $retransmit
    }
    exec awk $awkCode1 resultall.q
    exec awk $awkCode2 tcprtx.q
    exit 0
}

$ns run
