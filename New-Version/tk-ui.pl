use Tk;
use Tk::ROText;

#---------------------------------------
#sub Quit {
#	exit(0);
#}

my $VersionN = "Yahscrewed v0.71a";

#&SetConfig();
#&SetIggy();
#&SetFriends();

$MainW = MainWindow -> new();
$MainW->minsize(635, 510);
$MainW->geometry('635x510+50+50');
$MainW->setPalette('grey60');

#---------------------------------------
sub LoginBox {
	$LoginTF = $MainW->Toplevel();
	$LoginTF->geometry('+100+100');
	$LoginTF->title("Yahscrewed Login");
	$LabelFrame = $LoginTF->Frame()->pack('-side' => 'left','-fill' => 'both');
	$LabelFrame->Label('-text' => 'UserName:')->pack('-fill' => 'both');
	$LabelFrame->Label('-text' => 'Password:')->pack('-fill' => 'both');
	$LabelFrame->Label('-text' => 'Room:')->pack('-fill' => 'both');

	$EntryFrame = $LoginTF->Frame()->pack('-side' => 'right','-fill' => 'both');
	$NameEntBox = $EntryFrame->Entry('-bg' => 'black',
									'-fg' => 'white',
					#'insertbackground' => 'white',
					'-textvariable' => \$ConfigHash{"user_name"}
					)->pack('-fill' => 'both');
	$NameEntBox->focus;
	$PassEntBox = $EntryFrame->Entry('-show' => '*',
									'-bg' => 'black',
									'-fg' => 'white',
					#'insertbackground' => 'white',
					'-textvariable' => \$ConfigHash{"pass_word"}
					)->pack('-fill' => 'both');
	$RoomEntBox= $EntryFrame->Entry('-bg' => 'black',
									'-fg' => 'white',
					#'insertbackground' => 'white',
					'-textvariable' => \$ConfigHash{"initial_room"}
					)->pack('-fill' => 'both');

	#$NameEntBox->bind('<KeyPress-Return>', \&GetLogin);
	#$PassEntBox->bind('<KeyPress-Return>', \&GetLogin);
	#$RoomEntBox->bind('<KeyPress-Return>', \&GetLogin);
}

#---------------------------------------

sub ChatterBox {
	$MainW->title($VersionN);
	#$MenuDrop=$MainW->Button(-command => {&LoginBox})->pack;
	$RoomListBox=$MainW->Scrolled('Listbox',
							'-height' => 20,
							'-width' => 15,
							'-bg' => 'black',
							'-fg' => 'white',
							'-scrollbars' => 'oe'
							)->pack('-side' => 'right',
							'-fill' => 'both');
	$TextBox = $MainW->Scrolled('ROText','-width' => 80,
						'-height' => 35,
						'-wrap' => 'word',
						'-takefocus' => 0,
						'-bg' => 'black',
						'-fg' => 'white',
						'-scrollbars' => 'oe')->pack('-fill' => 'both');
	$RoomLabel = $MainW->Button('-textvariable' => \$Room,
								'-justify' => 'left')->pack('-fill' => 'both');
	$TextEntBox = $MainW->Entry ('-width' => 60, '-bg' => 'black',
								'-fg' => 'white',
								#'insertbackground' => 'white'
								)->pack('-side' => 'bottom',
								'-fill' => 'both');
	$TextEntBox->focus;
	#$TextEntBox->bind('<KeyPress-Return>', \&GetMsg);
}

#---------------------------------------

#sub GetMsg {
#	my $TextMsg = $TextEntBox->get();
#	&PktTester($TextMsg);
#	$TextEntBox->delete(0, length($TextMsg));
#}

#---------------------------------------

#sub GetLogin {
#	$UserName = $NameEntBox->get();
#	$PassWord = $PassEntBox->get();
#	$RoomName = $RoomEntBox->get();
#	$NameEntBox->delete(0, length($UserName));
#	$PassEntBox->delete(0, length($PassWord));
#	$RoomEntBox->delete(0, length($RoomName));
#	chomp($UserName);
#	chomp($PassWord);
#	chomp($RoomName);
#	&KillWidget($LoginTF);
#	&GetCookie($UserName, $PassWord, $RoomName);
#}

#---------------------------------------

sub KillWidget {
	$_[0]->destroy;
}

#---------------------------------------

#sub TextPost {
#	my $MsgEntry = $_[0];
#	my $ColorCode = $_[1];
#	$TextBox->tagConfigure($ColorCode, -foreground => $ColorCode);
#	$TextBox->insert('end', $MsgEntry, $ColorCode);
#	$TextBox->see('end');
#}

#---------------------------------------

1;
