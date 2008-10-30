require "tk-ui.pl";
require "engine.pl";

&LoginBox();
&ChatterBox();

$NameEntBox->bind('<KeyPress-Return>', \&GetLogin);
$PassEntBox->bind('<KeyPress-Return>', \&GetLogin);
$RoomEntBox->bind('<KeyPress-Return>', \&GetLogin);

$TextEntBox->bind('<KeyPress-Return>', \&GetMsg);

sub Quit {
	exit(0);
}

&SetConfig();
&SetIggy();
&SetFriends();

#------------------------------------------

sub GetMsg {
        my $TextMsg = $TextEntBox->get();
        &PktTester($TextMsg);
        $TextEntBox->delete(0, length($TextMsg));
}

#------------------------------------------

sub GetLogin {
        $UserName = $NameEntBox->get();
        $PassWord = $PassEntBox->get();
        $RoomName = $RoomEntBox->get();
        $NameEntBox->delete(0, length($UserName));
        $PassEntBox->delete(0, length($PassWord));
        $RoomEntBox->delete(0, length($RoomName));
        chomp($UserName);
        chomp($PassWord);
        chomp($RoomName);
        &KillWidget($LoginTF);
        &GetCookie($UserName, $PassWord, $RoomName);
}

#---------------------------------------

sub TextPost {
	my $MsgEntry = $_[0];
	my $ColorCode = $_[1];
	$TextBox->tagConfigure($ColorCode, -foreground => $ColorCode);
	$TextBox->insert('end', $MsgEntry, $ColorCode);
	$TextBox->see('end');}

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

1;
