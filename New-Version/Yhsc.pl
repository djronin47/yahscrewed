#!/usr/bin/perl --

use YPacket;
#use YTK;
#use YControl;

my $uname = ;
my $passwd = ;
my $roomname = "linux, freebsd, solaris:1";

my $cookie = YPacket::get_cookie($uname,$passwd);
my $login_packet = YPacket::create_login_packet($uname,$cookie);
my $room_packet = YPacket::create_room_packet($roomname);

#print $cookie, "\n";
#print $login_packet, "\n";
#print $room_packet, "\n";

#MainLoop();
exit(0);
