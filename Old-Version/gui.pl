use Tk;
use Tk::ROText;

$MainW = MainWindow -> new();
$MainW->minsize(635, 510);
$MainW->geometry('635x510+50+50');
$MainW->setPalette('grey60');
$MainW->title($VersionN);

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
					'insertbackground' => 'white',
					'-textvariable' => \$ConfigHash{"user_name"}
					)->pack('-fill' => 'both');
	$NameEntBox->focus;
	$PassEntBox = $EntryFrame->Entry('-show' => '*',
									'-bg' => 'black',
									'-fg' => 'white',
					'insertbackground' => 'white',
					'-textvariable' => \$ConfigHash{"pass_word"}
					)->pack('-fill' => 'both');
	$RoomEntBox= $EntryFrame->Entry('-bg' => 'black',
									'-fg' => 'white',
					'insertbackground' => 'white',
					'-textvariable' => \$ConfigHash{"initial_room"}
					)->pack('-fill' => 'both');
	$NameEntBox->bind('<KeyPress-Return>', \&GetLogin);
	$PassEntBox->bind('<KeyPress-Return>', \&GetLogin);
	$RoomEntBox->bind('<KeyPress-Return>', \&GetLogin);
}

sub QuitApp {
	exit(0);
}

#---------------------------------------

sub ChatterBox {
	$MainMenu = $MainW->Menu;
	$MainW->configure(-menu => $MainMenu);
	$MainMenu->add('command', -label => "Logon", "-command" => \&LoginBox);
	$MainMenu->add('command', -label => "Quit", "-command" => \&QuitApp);
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
								'insertbackground' => 'white'
								)->pack('-side' => 'bottom',
								'-fill' => 'both');
	$TextEntBox->focus;
	$TextEntBox->bind('<KeyPress-Return>', \&GetMsg);
}

#---------------------------------------

sub GetMsg {
	my $TextMsg = $TextEntBox->get();
	&PktTester($TextMsg);
	$TextEntBox->delete(0, length($TextMsg));
}

#---------------------------------------

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

sub KillWidget {
	$_[0]->destroy;
}

#---------------------------------------

sub TextPost {
	my $MsgEntry = $_[0];
	my $ColorCode = $_[1];
	$TextBox->tagConfigure($ColorCode, -foreground => $ColorCode);
	$TextBox->insert('end', $MsgEntry, $ColorCode);
	$TextBox->see('end');
}

#---------------------------------------

sub ChatListPost {
	my $who = $_[0];
	chomp($who);
	my $num = $_[1];
	chomp($num);
	my $status = $_[2];
	chomp($status);

	my @LArray = $_[3];
	print @LArray, "\n";
	$RoomListBox->delete(0, 'end');
	
	for($status) {
		if(/^add/) {
			my @NArray = @LArray;
			push(@NArray, $who);
			print @NArray, "\n";
			my @APostArray = sort {uc($a) cmp uc($b)} @NArray;
			print @APostArray, "\n";
			#foreach $i (@APostArray)
			#	{ print $i, "\n"; }
			$RoomListBox->insert(0, @APostArray);
			$RoomListBox->see('end');
		}

		elsif(/^rm/) {
			my @RArray = @LArray;
			splice(@RArray, $num, 1);
			print @RArray, " removed\n\n";
			my @RPostArray = sort {uc($a) cmp uc($b)} @RArray;
			$RoomListBox->insert(0, @RPostArray);
			$RoomListBox->see('end');
			print @RPostArray, " new-array\n\n";
			#foreach $i (@RPostArray)
			#	{ print $i, "\n"; }
		} else {
			return;
		}
	}
}

#---------------------------------------

1;
