use IO::Select;
use IO::Socket;

package YPacket;

# some commonly used packet definitions
my $ycver = "YCHT" . "\x00\x01\x00\x00";
my $del1 = "\x01";
my $del2 = "\x00\x00";

# packet definitions for decoding
my $pm_packet = $ycver . "\x00\x00\x00\x45";
my $roomenter_packet = $ycver . "\x00\x00\x00\x11";
my $roomleave_packet = $ycver . "\x00\x00\x00\x12";
my $emoter_packet = $ycver . "\x00\x00\x00\x43";
my $thought_packet = $ycver . "\x00\x00\x00\x42";
my $pkt_spr = sprintf("%s", "\xc0\x80");

# snag and return cookie from cookie server
sub get_cookie {
	my $uname = shift;
	my $passw = shift;
	my $CookieHost = "login.yahoo.com";
	my $CookiePort = "http(80)";

	my @YhStr = ("Get /config/login?login=$uname",
		"&passwd=$passw", "&.chkP=Y", " HTTP/1.0\n\n");
	
	$CookieSrv = IO::Socket::INET -> new (
		PeerAddr => $CookieHost,
		PeerPort => $CookiePort,
		Proto => "tcp");
		unless ($CookieSrv) { die "cannot connect to Cookie Server" }
	$CookieSrv->autoflush(1);

	$CookieSrv->print(@YhStr);;

	while($_=$CookieSrv->getline) {
		$T = "$_\n" if /F=/;
		$CookieRtn1 = "$_\n" if /Y=v=/;
		$CookieRtn2 = "$_\n" if /T=z=/;
	}
	$CookieSrv->close;

	chomp($CookieRtn1);
	chomp($CookieRtn2);

	@TmpCookie1 = split / /, $CookieRtn1;
	@TmpCookie2 = split / /, $CookieRtn2;
	$TmpCookie2 = $TmpCookie2[1];
	substr($TmpCookie2, -1) = "";
	$Cookie = $TmpCookie1[1] . " " . $TmpCookie2;

	return($Cookie);
}

# create and return login packet
sub create_login_packet {
	my $uname = shift;
	my $cookie = shift;

	my $login_flag = "\x00\x00\x00\x01";

	my $l_size = length("$uname") + length("$cookie") + 1;
	$l_size = pack "H4", "\x" . sprintf("%x", $l_size);

	my $login_pkt = $ycver . $login_flag . $del2 . $l_size . $uname . $del1 . $cookie;

	return($login_pkt);
}

# create and return room login packet
sub create_room_packet {
	my $roomname = shift;
	my $room_flag = "\x00\x00\x00\x11";

	if(length($roomname) <= 14) {
		$room_pkt = pack "h4", "\x00\x" . sprintf("%x", length($roomname));
	} else {
		$room_pkt = pack "H4", "\x00\x" . sprintf("%x", length($roomname));
	}
	my $room_packet = $ycver . $room_flag . $del2 . $room_pkt . $roomname;

	return($room_packet);
}

# create and return chat packet
sub create_chat_packet {
	my $msg = shift;
	my $roomname = shift;
	my $chat_flag = "\x00\x00\x00\x41";

	if(length($msg) + length($roomname) + 1 <= 14) {
		my $chat_pkt = length($msg) + length($roomname) + 1;
		$chat_pkt = pack "h4", "\x00\x" . sprintf("%x", $chat_pkt);
	} else {
		my $chat_pkt = length($msg) + length($roomname) + 1;
		$chat_pkt = pack "H4", "\x00\x" . sprintf("%x", $chat_pkt);
	}
	my $chat_packet = $ycver . $chat_flag . $del2 . $chat_pkt . $roomname . $del1 . $msg;
	return($chat_packet);
}

#create and return a command packet
sub create_cmd_packet {
	my $command = shift;
	my $roomname = shift;
	my $cmd_flag = "\x00\x00\x00\x41";

	$command = substr($command, 1);
	$cmd_output = readpipe($command);
	$cmd_output = "\n$cmd_output";

	if(length($cmd_output) + length($roomname) + 1 <= 14) {
		my $cmd_pkt = length($cmd_output) + length($roomname) + 1;
		$cmd_pkt = pack "h4", "\x00\x" . sprintf("%x", $cmd_pkt);
	} else {
		my $cmd_pkt = length($cmd_output) + length($roomname) + 1;
		$cmd_pkt = pack "H4", "\x00\x" . sprintf("%x", $cmd_pkt);
	}
	my $cmd_msg = $ycver . $cmd_flag . $del2 . $cmd_pkt . $roomname . $del1 . $cmd_output;
	return($cmd_msg);
}

# create and return an emote packet
sub create_emote_packet {
	my $emote = shift;
	my $roomname = shift;
	my $emote_flag = "\x00\x00\x00\x43";

	my $emote = substr($emote, 1);

	if(length($emote) + length($roomname) + 1 <= 14) {
		my $emote_pkt = length($emote) + length($roomname) + 1;
		$emote_pkt = pack "h4", "\x00\x" . sprintf("%x", $emote_pkt);
	} else {
		my $emote_pkt = length($emote) + length($roomname) + 1;
		$emote_pkt = pack "H4", "\x00\x" . sprintf("%x", $emote_pkt);
	}
	my $emotemsg = $ycver . $emote_flag . $del2 . $emote_pkt . $roomname . $del1 . $emote;
	return($emotemsg);
}

# create and return a thought packet
sub create_think_packet {
	my $thought = shift;
	my $tnk = "think ";
	my $think_flag = "\x00\x00\x00\x71";
	my $thought = substr($thought, 7);
	if(length($thought) + length($tnk) <= 14) {
		my $think_pkt = length($thought) + length($tnk);
		$think_pkt = pack "h4", "\x00\x" . sprintf("%x", $think_pkt);
	} else {
		my $think_pkt = length($thought) + length($tnk);
		$think_pkt = pack "H4", "\x00\x" . sprintf("%x", $think_pkt);
	}
	my $think_msg = $ycver . $think_flag . $del2 . $think_pkt . $tnk . $thought;
	return($think_msg);
}

# create and return a pm packet
sub create_pm_packet {
	my $person = shift;
	my $pm = shift;
	my $uname = shift;
	my $pm_flag = "\x00\x00\x00\x45";

	if(length($person) + length($pm) + 1 <= 14) {
		my $pm_pkt = length("$pm") + length("person");
		$pm_pkt = pack "h4", "\x00\x" . sprintf("%x", $pm_pkt);
  } else {
		my $pm_pkt = length("pm") + length($person);
		$pm_pkt = pack "H4", "\x00\x" . sprintf("%x", $pm_pkt);
	}
	my $pm_msg = $ycver . $pm_flag . $del2 . $pm_pkt . $uname . $del1  . $person . $del1 . $pm_pkt;
}

# decode incoming packets
sub decode_packet_type {
	my $packet_todecode = shift;
	my $packet_type;
	for($packet_todecode) {
		if(/^$pm_packet/) { $packet_type = "pm"; }
		elsif(/^$roomenter_packet/) {$packet_type = "roomenter"; }
		elsif(/^$roomleave_packet/) {$packet_type = "roomleave"; }
		elsif(/^$emoter_packet/) { $packet_type = "emoter"; }
		elsif(/^thought_packet/) { $packet_type = "thought"; }
	}
	return($packet_type);
}

# extract the important packet data
sub filter_packet {
	my $p_type = shift;
	my $packet = shift;
	my $new_packet;

	$new_packet = substr($packet, 16);

	for($new_packet) {
		s/^\x7f//g;
	}
}
1;
