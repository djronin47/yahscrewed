use IO::Select;
use IO::Socket;

my $VersionN = "Yahscrewed v0.666.666 (Hellish Chaos version)";

$uname=;
$passwd=";

#---------------------------------------

sub GetCookie {
	my $CookieHost = 'login.yahoo.com';
	my $CookiePort = "http(80)";

	my $name = $_[0];
	my $passw = $_[1];

	my @Yhstr = ("GET /config/login?login=$name",
		"&passwd=$passw", "&.chkP=Y", " HTTP/1.0\n\n");

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
	my $LgnPkt = "\x00\x00\x00\x01\x00\x00";

	my $Size = length("$name") + length("$cooky") + 1;

	$Size = pack "H4", "\x" . sprintf("%x", $Size);

	my $TestStr = $YCVer . $LgnPkt . $Size . $name . $Del1 . $cooky;

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

        $ChatSrv->send($RoomEnt);
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
        #SendPkt($ChatMsg);
	$ChatSrv->send($ChatMsg);

}

#while(1) {
#	print "1";
#}

#sub SendPkt {
        #if ($Select->can_write(.03125)) {
#        $ChatSrv->send($_[0]);
        #}
#}

        #for($count = 1; $count < 11; $count++) {
        #        print $count;
        #}
#---------------------------------------

GetCookie($uname,$passwd);
YahooLogon($uname,$Cookie);
RoomEnter("linux, freebsd, solaris:1");
SendMsg("testing testing");
