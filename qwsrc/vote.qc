// *****************************************************************
//  Pure CTF v1.99beta4 by Dan "Methabol" Zetterström 1998-08-??
//  Pure CTF Homepage: http://purectf.solgames.com/
//  Report bugs and ideas to: methabol@bt.nu
// *****************************************************************

//  check -->


float VOTE_YES = 1;
float VOTE_NO = 2;
float VOTE_START = 4;

float VOTED_YES;
float VOTED_NO;
float VOTED_NOTHING;

void() VOTE_FUNCTION = {};
string VOTE_TEXT;
entity VOTE_STARTER;
float VOTE_TIMEOUT;

float VOTEEXIT_FLAG;

void() ClearVote = {
	local entity e;
	e = PLAYER_CHAIN;
	while(e) {
		e.voted = e.voted - (e.voted & (VOTE_YES | VOTE_NO));
		e = e.clientchain;
	}
	VOTED_YES = 0;
	VOTED_NO = 0;
	VOTED_NOTHING = 0;
	VOTE_FUNCTION = SUB_Null;
	VOTE_TEXT = string_null;	
	VOTE_STARTER = world;
	VOTE_TIMEOUT = 0;
};	


void() CheckVotes = {
	local entity e;
	local float x;
	local string tp;
	VOTED_YES = 0;
	VOTED_NO = 0;
	VOTED_NOTHING = 0;
	e = PLAYER_CHAIN;
	while (e) {
		if (e.voted & VOTE_YES)
			VOTED_YES = VOTED_YES + 1;		
		else if (e.voted & VOTE_NO)
			VOTED_NO = VOTED_NO + 1;	
		else 
			VOTED_NOTHING = VOTED_NOTHING + 1;		
		e = e.clientchain;
	}
	if (VOTED_YES > (VOTED_NO + VOTED_NOTHING)) {
		bprint(PRINT_HIGH, " Vote passed!\n");	
		VOTE_FUNCTION();
		ClearVote();
	} else	if (VOTED_NO > (VOTED_YES + VOTED_NOTHING)) {
		bprint(PRINT_HIGH, " Vote Failed.\n");	
		ClearVote();
	} else {
		x = ceil((1+ VOTED_NO + VOTED_NOTHING - VOTED_YES) / 2);
		tp = ftos(x);
		bprint(PRINT_HIGH, " ");
		bprint(PRINT_HIGH, tp);
		bprint(PRINT_HIGH, " more vote");
		if (x > 1) bprint(PRINT_HIGH, "s");
		bprint(PRINT_HIGH, " are needed.\n");
	}
};

void(string votetext, void() votefunction) StartVote = {
	local entity e;
	if (VOTE_TIMEOUT) {
		sprint(self, PRINT_HIGH,  "Vote already in progress.\n");
		return;
	}
	if (self.voted & VOTE_START) {
		sprint(self, PRINT_HIGH,  "You only get one vote per map\n");
		return;
	}		

	VOTE_TEXT = votetext;
	VOTE_STARTER = self;
	VOTE_TIMEOUT = time + 45;
	VOTE_FUNCTION = votefunction;

	bprint(PRINT_HIGH, VOTE_STARTER.netname);
	bprint(PRINT_HIGH, " wants to ");
	bprint(PRINT_HIGH, VOTE_TEXT);
	bprint(PRINT_HIGH, " Type ÙÅÓ or ÎÏ to Vote. ");
	self.voted = VOTE_START | VOTE_YES;
	CheckVotes();
	sprint(self, PRINT_HIGH, "Vote started. Stop it with 'óôïðöïôå'\n");
};

void() StopVote = {
	if (self == VOTE_STARTER) {
		bprint(PRINT_HIGH, self.netname);
		bprint(PRINT_HIGH, " aborted the vote.\n");
		ClearVote();
	}
};

void() VoteYes = {
	if (self.voted & VOTE_YES)
		return;
	if (!VOTE_TIMEOUT)
		return;
	self.voted = (self.voted | VOTE_YES) - (self.voted & VOTE_NO);
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " voted yes.");
	CheckVotes();
};
void() VoteNo = {
	if (self.voted & VOTE_NO)
		return;
	if (!VOTE_TIMEOUT)
		return;
	self.voted = (self.voted | VOTE_NO) - (self.voted & VOTE_YES);
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " voted no.");
	CheckVotes();
};


void() VotedExitmap = {
	EndMatch();
};

void() StartVoteExit = {
	if (FLAG_COMPETITION) {
		sprint(self, PRINT_HIGH, "You can't voteexit in competition.\n");
	} else if (!FLAG_VOTEEXIT) {
		sprint(self, PRINT_HIGH, "Voteexit disabled.\n");
	} else if (VOTEEXIT_FLAG) {
		sprint(self, PRINT_HIGH, "Only one voteexit per map.\n");
	} else if (time < 20) {
		sprint(self, PRINT_HIGH, "You can't voteexit the first 20 seconds.\n");
	} else {
		VOTEEXIT_FLAG = 1;
		StartVote("exit this map.", VotedExitmap);
	}
};

void() VoteBreak = {
	// *check*
	if (VOTE_TIMEOUT)
		VoteYes();
	else {
		StartVote("break the game.", EndMatch);
	}
};

void() StartAdminVote = {
	if (self.admin & AD_ADMIN) {
		RemoveAdminflags();		// "admin" doubles as admin remover
	} else if (!FLAG_ADMINVOTE) {
		sprint(self, PRINT_HIGH, "Admin by vote disabled.\n");
	} else {
		StartVote("become an admin.", AdminVoted);
	}
};



float () VoteCenterprint = {
	local string s1,s2,s3,s4,ss;
	if (!VOTE_TIMEOUT)
		return 0;
	if (self.voted & (VOTE_YES | VOTE_NO))
		return 0;
	s1 = VOTE_STARTER.netname;
	s2 = " wants to\n";
	s3 = VOTE_TEXT;
	s4 = "\n\nType ÙÅÓ or ÎÏ in the\nconsole to vote.\n";
	ss = "*****************************\n*****************************\n*****************************\n";
	centerprint6(self, ss, s1,s2,s3,s4, ss);
	return 1;
};


void()	CheckVoteTimeout = {
	if (VOTE_TIMEOUT > time)
		return;
	bprint(PRINT_HIGH, "Vote aborted. (timeout)\n");
	ClearVote();
};



//  <-- check
