<?php

# ソースIPを指定してtargetにPINGをする
# targetのARPをいろいろ呼び起こす

$target = array("10.1.1.1");

if($argv) {

    $ip_addr = $argv[1];

    // ping body
    $package = "\x08\x00\x19\x2f\x00\x00\x00\x00\x70\x69\x6e\x67";

    // main loop
    for($i = 0;  $i < count($target); $i++) {

        print "ping:" . $target[$i] . ": using: " . $ip_addr . "\n";

        $sock = socket_create(AF_INET, SOCK_RAW, 1);

        // socket properties
        $sec = Array("sec" => 5, "usec" => 0);
        socket_set_option($sock, SOL_SOCKET, SO_SNDTIMEO, $sec);
        socket_set_option($sock, SOL_SOCKET, SO_RCVTIMEO, $sec);

        socket_bind($sock, $ip_addr);

        if($socket_error = socket_last_error()) {
            print socket_strerror($socket_error) . ":" . $to . "\n";
            exit;
        }

        socket_connect($sock, $target[$i], null);

        if(!socket_send($sock, $package, strlen($package), 0)) {
            print "Socket Error\n";
            socket_close($sock);
            exit;
        }

        socket_close($sock);

    }

} else {
    print "source ip ping dekityau!\n";
    print "usage : ping.php [sourece_ip]\n";
    exit;
}

exit;

?>

