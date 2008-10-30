use IO::Select;
use IO::Socket;

my $VersionN = "Yahscrewed v0.666.666 (Hellish Chaos version)";

require "tk-ui.pl";

#---------------------------------------

sub GetCookie {
	my $CookieHost = 'login.yahoo.com';
	my $CookiePort = "http(80)";

	my @Yhstr = ("GET /config/login?login=$uname",
		"&passwd=$passwd", "&.chkP=Y", " HTTP/1.0\n\n");

	$CookieSrv = IO::Socket::INET -> new (
		PeerAddr => $CookieHost,
		PeerPort => $CookiePort,
		Proto => "tcp");
		unless ($CookieSrv) { die "cannot connect to Cookie server" }
	$CookieSrv->autoflush(1);
	
	$CookieSrv->print(@Yhstr);

	while($_=$CookieSrv->getline) {
		$T = "$_\n" if /F=a=/;
		$CookieRtn1 = "$_\n" if /Y=v=/;
		$CookieRtn2 = "$_\n" if /T=z=/;
	}
	$CookieSrv->close;
	chomp($CookieRtn1);
	chomp($CookieRtn2);

	@TmpCookie1 = split / /, $CookieRtn1;
	$TmpCookie1 = $TmpCookie1[1];

	@TmpCookie2 = split / /, $CookieRtn2;
	$TmpCookie2 = $TmpCookie2[1];

	substr($TmpCookie2, -1) = "";

	$Cookie = $TmpCookie1 . " " . $TmpCookie2;

	return($Cookie);
}

#---------------------------------------

sub YahooLogon {
	my $ChatHost = 'jcs.chat.yahoo.com';
	my $ChatPort = 8001;

	my $name = $_[0];
	my $cooky = $_[1];

	my $YCVer = "YCHT" . "\x00\x01\x00\x00";
	my $Del1 = "\x01";
	my $LoginPkt = "\x00\x00\x00\x01\x00\x00";

	my $Size = length($name) + length($cooky) + 1; 

	$Size = pack "H4", "\x" . sprintf("%x", $Size);

	my $TestStr = $YCVer . $LoginPkt . $Size . $name . $Del1 . $cooky;

	$ChatSrv = IO::Socket::INET -> new (
		PeerAddr => $ChatHost,
		PeerPort => $ChatPort,
		Proto => "tcp");
		unless ($ChatSrv) { die "cannot connect to chat server" }
	$ChatSrv->autoflush(1);
	
	$Select = IO::Select->new($ChatSrv);
	$Select->add($ChatSrv);

	$ChatSrv->send($TestStr);
}

#---------------------------------------

sub RoomEnter {
	my $YVer = "YCHT" . "\x00\x01\x00\x00";
	my $Del2 = "\x00\x00";
	$Room = $_[0];
	if(length($_[0]) <= 14) {
		$RoomPkt = pack "h4", "\x00\x" . sprintf("%x", length($_[0])); 
	} else {
		$RoomPkt = pack "H4", "\x00\x" . sprintf("%x", length($_[0])); 
	}
	my $RoomFlg = "\x00\x00\x00\x11";
	my $RoomEnt = $YVer . $RoomFlg . $Del2 . $RoomPkt . $_[0];
	
	$ChatSrv->print($RoomEnt);

#---------------------------------------

sub FindChatterNum {
	my @FArray = $RoomListBox->get(0, 'end');
	my $FArrayLengh = $RoomListBox->size;
	
	my $fwho = $_[0];
	
	my $fi;
	
	for($fi = 0; $fi <= $FArrayLength; $fi++) {
		if(lc($fwho) eq lc($FArray[$fi])) {
			return($fi);
		} 
	}
}

#---------------------------------------

sub SetListener {
	while(1) {
		$MainW->update();
		if($Select->can_read(.03125)) {
			&RecvInfo();
		}
	}
}

#---------------------------------------

sub SendMsg {
	my $YVer = "YCHT" . "\x00\x01\x00\x00";
	my $Del2 = "\x00\x00";
	my $Del1 = "\x01";
	my $TlkFlg = "\x00\x00\x00\x41";
	if(length($Room) + length($_[0]) + 1 <= 14) {
		my $STlkPkt = length($Room) + length($_[0]) + 1;
		$TlkPkt = pack "h4", "\x00\x" . sprintf("%x", $STlkPkt);
	} else {
		my $LTlkPkt = length($Room) + length($_[0]) + 1;
		$TlkPkt = pack "H4", "\x00\x" . sprintf("%x", $LTlkPkt);
	}
	my $ChatMsg = $YVer . $TlkFlg . $Del2 . $TlkPkt . $Room . $Del1 . $_[0];
	&SendPkt($ChatMsg);
}

#---------------------------------------

sub SendCMD {
	my $YVer = "YCHT" . "\x00\x01\x00\x00";
	my $Del2 = "\x00\x00";
	my $Del1 = "\x01";
	my $TlkFlg = "\x00\x00\x00\x41";
	my $CMD = $_[0];
	$CMD = substr($CMD, 1);
	$OCMD = readpipe($CMD);
	$NCMD = "\n$OCMD";
	if(length($Room) + length($NCMD) + 1 <= 14) {
		my $SCMDPkt = length($Room) + length($NCMD) + 1;
		$CMDPkt = pack "h4", "\x00\x" . sprintf("%x", $SCMDPkt);
	} else { 
		my $LCMDPkt = length($Room) + length($NCMD) + 1;
		$CMDPkt = pack "H4", "\x00\x" . sprintf("%x", $LCMDPkt);
	}
	my $CMDMsg = $YVer . $TlkFlg . $Del2 . $CMDPkt . $Room . $Del1 . $NCMD;
	&SendPkt($CMDMsg);
}

#---------------------------------------

sub SendEmote {
	my $YVer = "YCHT" . "\x00\x01\x00\x00";
	my $Del2 = "\x00\x00";
	my $Del1 = "\x01";
	my $EMsg = $_[0];
	$EMsg = substr($EMsg, 1);
	my $EmoteFlg = "\x00\x00\x00\x43";
	if(length($Room) + length($EMsg) + 1 <= 14) {
		my $SEmotePkt = length($Room) + length($EMsg) + 1;
		$EmotePkt = pack "h4", "\x00\x" . sprintf("%x", $SEmotePkt);
	} else {
		my $LEmotePkt = length($Room) + length($EMsg) + 1;
		$EmotePkt = pack "H4", "\x00\x" . sprintf("%x", $LEmotePkt);
	}
	my $Emote = $YVer . $EmoteFlg . $Del2 . $EmotePkt . $Room . $Del1 . $EMsg;
	&SendPkt($Emote);
}

#---------------------------------------

sub SendThink {
	my $YVer = "YCHT" . "\x00\x01\x00\x00";
	my $Del2 = "\x00\x00";
	my $TMsg = $_[0];
	$TMsg = substr($TMsg, 7);
	my $ThnkFlg = "\x00\x00\x00\x71";
	if(length("think ") + length($TMsg) <= 14) {
		my $SThnkPkt = length("think ") + length($TMsg);
		$ThnkPkt = pack "h4", "\x00\x" . sprintf("%x", $SThnkPkt);
	} else {
		my $LThnkPkt = length("think ") + length($TMsg);
		$ThnkPkt = pack "H4", "\x00\x" . sprintf("%x", $LThnkPkt);
	}
	my $ThnkMsg = $YVer . $ThnkFlg . $Del2 . $ThnkPkt . "think " . $TMsg;
	&SendPkt($ThnkMsg);
}

#---------------------------------------

sub SendPM {
	my $YVer = "YCHT" . "\x00\x01\x00\x00";
	my $Del1 = "\x01";
	my $Del2 = "\x00\x00";
	my $UName = $UserName;
	my $PMsg = $_[0];
	my @PMI = split / /, $PMsg;
	my @MMI = @PMI;
	splice(@PMI, 0, 2);
	my $M = &PMaker(@PMI);
	my $PMFlg = "\x00\x00\x00\x45";
	if(length($UName) + 1 + length($MMI[1]) + 1 + length($M) <= 14) {
		my $SPM = length($UName) + 1 + length($MMI[1]) + 1 + length($M);
		$PMPkt = pack "h4", "\x00\x" . sprintf("%x", $SPM);
	} else {
		my $LPM = length($UName) + 1 + length($MMI[1]) + 1 + length($M);
		$PMPkt = pack "H4", "\x00\x" . sprintf("%x", $LPM);
	}
	my $PMMsg = $YVer . $PMFlg . $Del2 . $PMPkt . $UName . $Del1 . $MMI[1] . $Del1 . $M;
	&SendPkt($PMMsg);
	my $Info = "<You tell " . $MMI[1] . " - " . $M . ">\n";
	return($Info, $ConfigHash{"own_color"});
}

#---------------------------------------

sub PMaker {
	my @n = @_;
	my $stop = @_;
	my $o;
	for($i = 0; $i < $stop; $i++) {
		$o = $o . " " . $n[$i];
	}
	my $b = $o;
	chomp($b);
	substr($b, 0, 1) = "";
	return($b);
}

#---------------------------------------

sub SendPkt {
	if ($Select->can_write(.03125)) {
	$ChatSrv->send($_[0]);
	}
}

#---------------------------------------

sub RecvInfo {
	my $PMDel = $YVer . sprintf("%s", "\x00\x00\x00\x45");
	my $REDel = $YVer . sprintf("%s", "\x00\x00\x00\x11");
	my $RLDel = $YVer . sprintf("%s", "\x00\x00\x00\x12");
	my $EMDel = $YVer . sprintf("%s", "\x00\x00\x00\x43");
	my $THDel = $YVer . sprintf("%s", "\x00\x00\x00\x42");
	if($Select->can_read(.03125)) {
		$ChatSrv->recv($YahooRecv, 1024);
		substr($YahooRecv, 54);
		for($YahooRecv) {
			if (/^$PMDel/) { &PMPost($YahooRecv); }
			elsif (/^$REDel/) { &REPost($YahooRecv); }
			elsif (/^$RLDel/) { &RLPost($YahooRecv); }
			elsif (/^$EMDel/) { &EMPost($YahooRecv); }
			elsif (/^$THDel/) { &EMPost($YahooRecv); }
			else { &CRoomPost($YahooRecv); }
		}
		$YahooRecv = "";
	}
}

#---------------------------------------

sub PMPost {
	my $PPkt = $_[0];
	substr($PPkt, 16);
	my $PMDel = $YVer . sprintf("%s", "\x00\x00\x00\x45");
	for($PPkt) {
		s/^\x7f//g;
		s/^$PMDel//g;
	}
	my $DelPkt = sprintf("%s", "\xc0\x80");
	my $NewPkt = substr($PPkt, 4);
	my @OutPkt = split /$DelPkt/, $NewPkt;

	if(exists $IggyHash{ $OutPkt[0] }) { 
		return; 
	}
	
	my $OutPut = "<" . $OutPkt[0] . "> [PM]\n    " . $OutPkt[2] . "\n";
	
	if(exists $FriendHash{ $OutPkt[0] })
		{ return($OutPut, $ConfigHash{"pm_color"}); }
	else
		{ return($OutPut, $ConfigHash{"pm_color"}); }
}

#---------------------------------------

sub REPost {
	my $REPkt = $_[0];
	$REPkt = substr($REPkt, 16);
	my $REDel = $YVer . sprintf("%s", "\x00\x00\x00\x11");
	for($REPkt) {
		s/^\x7f//g;
		s/^$REDel//g;
	}
	my $DelPkt = sprintf("%s", "\xc0\x80");
	my @OutPkt = split /$DelPkt/, $REPkt;
	$OutPkt[4] =~ s/\x01//g;
	$OutPkt[4] =~ s/\x020\x02 \x020\x020\x02//g;
	if (exists $IggyHash{ $OutPkt[4] }) {
		return; 
	}
	
	my $OutPut = "-[ " . $OutPkt[4] . " has entered the room ]-\n";
	
	if(exists $FriendHash{ $OutPkt[4] })
		{ return($OutPut, $ConfigHash{"friend_color"}); }
	else
		{ return($OutPut, $ConfigHash{"enter_color"}); }
}

#---------------------------------------

sub RLPost {
	my $RLPkt = $_[0];
	$RLPkt = substr($RLPkt, 16);
	my $RLDel = $YVer . sprintf("%s", "\x00\x00\x00\x12");
	for($RLPkt) {
		s/^\x7f//g;
		s/^$RLDel//g;
	}
	my $DelPkt = sprintf("%s", "\xc0\x80");
	my @OutPkt = split /$DelPkt/, $RLPkt;
	
	if (exists $IggyHash{ $OutPkt[1] }) {
		return; 
	}

	my $OutPut = "-[ " . $OutPkt[1] . " has left the room ]-\n";

	if(exists $FriendHash{ $OutPkt[1] })
		{ return($OutPut, $ConfigHash{"friend_color"}); }
	else
		{ return($OutPut, $ConfigHash{"exit_color"}); }
}

#---------------------------------------

sub EMPost {
	my $EMPkt = $_[0];
	$EMPKt = substr($EMPkt, 16);
	my $EMDel = $YVer . sprintf("%s", "\x00\x00\x00\x43");
	for($EMPkt) {
		s/^\x7f//g;
		s/^$EMDel//g;
	}
	my $DelPkt = sprintf("%s", "\xc0\x80");
	my @OutPkt = split /$DelPkt/, $EMPkt;
	
	if (exists $IggyHash{ $OutPkt[1] }) {
		return;
	}
	
	my $OutPut = "<" . $OutPkt[1] . ">\n    " . $OutPkt[2] . "\n";
	
	if($OutPkt[1] eq $UserName)
		{ return($OutPut, $ConfigHash{"own_color"}); }
	elsif(exists $FriendHash{ $OutPkt[1] }) 
		{ return($OutPut, $ConfigHash{"friend_color"}); } 
	else 
		{ return($OutPut, $ConfigHash{"emote_color"}); }
}

#---------------------------------------

sub CRoomPost {
	my $CPkt = $_[0];
	my $DelPkt = sprintf("%s", "\xc0\x80");
	my $NewPkt = substr($CPkt, 16);
	my @OutPkt = split /$DelPkt/, $NewPkt;
	foreach(@OutPkt) {
		s/\x1b\[[0-9][0-9]m//g;
		s/\x1b[^m]*m//g;
		s/\x1b\[[0-9]m//g;
		s/\x1b\[\wm//g;
		s/\x1b\[30m//g;
		s/\\x1b\[30m//g;
		s/\x1b\[\w\wm//g;
		s/\x1b\[#\w\{6\}m//g;
		s/\\x1b\[#\w\{6\}m//g;
		s/<fade[^>]*>//gi;
		s/<\/fade[^>]*>//gi;
		s/<font[^>]*>//gi;
		s/<\/font[^>]*>//gi;
	}
	
	if (exists $IggyHash{ $OutPkt[1] }) {
		return;
	}
	
	my $OutPut = "[" . $OutPkt[1] . "]\n    " . $OutPkt[2] . "\n";
	
	if($OutPkt[1] eq $UserName)
		{ return($OutPut, $ConfigHash{"own_color"}); }
	elsif(exists $FriendHash { $OutPkt[1] })
		{ return($OutPut, $ConfigHash{"friend_color"}); }
	else { return($OutPut, $ConfigHash{"text_color"}); }
}

#---------------------------------------

sub PktTester {
	my $Msg = $_[0];
	chomp($Msg);
	my $HMsg = HelpList();
	my $YhVer = " Is using $VersionN\n(www.ronin47.com - random chaos yeah we got that)";

	for($Msg) {
		if(/^:\)/) { &SendMsg($Msg); }
		elsif(/^:/) { &SendEmote($Msg); }
		elsif(/^\/unmute/) { &RmIggy($Msg, "muted"); }
		elsif(/^\/mute/) { &AddIggy($Msg, "muted"); }
		elsif(/^\/unignore/) { &RmIggy($Msg, "ignored"); }
		elsif(/^\/ignore/) { &AddIggy($Msg, "ignored"); }
		elsif(/^\/help/) { &TextPost($HMsg); }
		elsif(/^\/ver/) { &SendEmote($YhVer); }
		elsif(/^\/think/) { &SendThink($Msg); }
		elsif(/^\/join/) {
			$Msg = substr($Msg, 6);
			&RoomEnter($Msg);
		}
		elsif(/^\/tell/) { &SendPM($Msg); }
		elsif(/^!/) { &SendCMD($Msg); }
		elsif(/^\/quit/) { &Quit; }
		else { &SendMsg($Msg); }
	}
}

#---------------------------------------

sub HelpList {
	my $Text = "
	+-----------------------------------------------+
	|  Command           Use                        |
	|-----------------------------------------------|
	|  :                 Emotes                     |
	|  /ver              Print version info         |
	|  /help             I think you know           |
	|  /tell <name>      Send a private message     |
	|  /ignore <name>    Ignore a user (forever)    |
	|  /unignore <name>  User is no longer ignored  |
	|  /mute <name>      Ignore a user (session)    |
	|  /unmute <name>    Listen to a user           |
	|  /think            Show the room thoughts     |
	|  !<cmd>            Execute a shell command    |
	|  /quit             Close program              |
	+-----------------------------------------------+\n\n";
	return $Text;
}

#---------------------------------------

sub AddIggy {
	my ($Name, $Cmd, $Msg);

	($Cmd, $Name) = split(/ /, $_[0], 2);
	$Msg = "$Name will now be $_[1].\n";

	if($_[1] eq "ignored"){
		unless ( open(FILE, ">>$IggyFile") ){
			$Msg = "Unable to open $IggyFile: $!\n";
			&TextPost($Msg, 'e');
			return;
		}
		print FILE $Name;
		close(FILE);
	}
	$IggyHash{$Name}=1;
	&TextPost($Msg, 'e');	
}

#---------------------------------------

sub RmIggy {
	my ($Name, $Cmd, $msg);

	($Cmd, $Name) = split(/ /, $_[0], 2);
	$Msg = "$Name is no longer $_[1]\n";

	delete $IggyHash{ $Name };
	if($_[1] eq "ignored"){
		unless ( open(FILE, ">$IggyFile") ){
			$Msg = "Unable to open $IggyFile: $!\n";
			&TextPost($Msg, 'e');
			return;
		}
		foreach $Name (keys %IggyHash) {
			print FILE $Name;
		}
		close(FILE);
	}
	&TextPost($Msg, 'e');
}

#---------------------------------------

sub SetIggy {
	my ($name, $line);
	$IggyFile = "ignore";
	%IggyHash;

	unless ( open(FILE, $IggyFile) ){
		print STDERR "Unable to open $IggyFile: $!\n";
		return;
	}
        while(<FILE>){  $line .= $_; }
        close(FILE);

        while( $line ne ""){
                ($name, $line) = split('\n', $line, 2);
		$IggyHash{$name} = 1;
	}
	return;
}

#---------------------------------------

sub SetFriends {
	my ($name, $line);
	$FriendFile = "friends";
	%FriendHash;

	unless ( open(FILE, $FriendFile) ){
		print STDERR "Unable to open $FriendFile: $!\n";
		return;
	}
        while(<FILE>){  $line .= $_; }
        close(FILE);

        while( $line ne ""){
                ($name, $line) = split('\n', $line, 2);
		$FriendHash{$name} = 1;
	}
	return;
}

#---------------------------------------

sub SetConfig {
	my($line, $key, $data);
	my $ConfigFile = "config";
	%ConfigHash;

	unless ( open(FILE, $ConfigFile) ) {
		die "Unable to open $ConfigFile: $!\n"
	}
		while(<FILE>){ $line .= $_; }
		close(FILE);
	
	$line =~ s/#.*\n//g;
		while( $line ne "") {
			($key, $line) = split('=', $line, 2);
			($data, $line) = split('\n', $line, 2);
		$key =~ s/ *$//;
		$key =~ s/^ *//;
		$data =~ s/^ *//;
		$data =~ s/ *$//;
		$ConfigHash{$key} = $data;
	}
	return;
}
}
#---------------------------------------

}1;
