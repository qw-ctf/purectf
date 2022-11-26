
.float laststattime;		// time of last status update
.float motd_count;
.float statoff;				// is the status bar on?

float teamscr1;			// team 1's teamscr score
float teamscr2;			// team 2's teamscr score
float lastteamscrtime;		// last time we calculated it

float TEAMSCRTIME = 1;
float PLAYERSTATTIME = 1.75;

void() MOTD =
{
	if (self.motd_count < 4) {
		self.motd_count = self.motd_count + 1;
		if (gamestart) {
			centerprint(self, "Welcome!\nRunning ThreeWave CTF 4.0\n\nцаптуре тхе флаг!\n\nChoose an exit...\n"); //red
			return;
		}
		if (self.team == TEAM_COLOR1)
			centerprint(self, "Welcome!\nRunning ThreeWave CTF 4.0\n\nцаптуре тхе флаг!\n\nYou are ред team\n"); //red
		else
			centerprint(self, "Welcome!\nRunning Threewave CTF 4.0\n\nцаптуре тхе флаг!\n\nYou are блуе team"); //blue
		return;
	}
	self.motd_count = 0;
};

void() MOTD_ChooseTeam =
{
	if (self.motd_count < 6) {
		self.motd_count = self.motd_count + 1;
		centerprint(self, "Welcome!\nRunning ThreeWave CTF 4.0\n\nцаптуре тхе флаг!\n\nPress 1 for ред team\nPress 2 for блуе team\nOr Press Jump for automatic team\n");
		return;
	}
	self.motd_count = 0;
};

void() TeamCaptureCheckUpdate =
{
	local entity p;

	if (gamestart)
		return; // handled by vote exit
	if (lastteamscrtime > time)
		return;

	lastteamscrtime = time + TEAMSCRTIME;

	// count up teamscr
	teamscr1 = teamscr2 = 0;
	p = find(world, classname, "player");
	while (p != world) {
		if (p.lastteam == TEAM_COLOR1)
			teamscr1 = teamscr1 + p.frags;
		else if (p.lastteam == TEAM_COLOR2)
			teamscr2 = teamscr2 + p.frags;
		p = find(p, classname, "player");
	}
};

void() TeamCaptureResetUpdate =
{
	lastteamscrtime = 0;
	TeamCaptureCheckUpdate();
};

void() TeamEndScore = 
{
	local string s;

	if (gamestart)
		return;

	lastteamscrtime = 0;
	TeamCaptureCheckUpdate();

	if (teamscr1 > teamscr2) {
		bprint("ред team won the level with ");
		s = ftos(teamscr1);
		bprint(s);
		bprint(" points!\n");
		bprint("блуе team lost with ");
		s = ftos(teamscr2);
		bprint(s);
		bprint(" points.\n");
	} else if (teamscr1 < teamscr2) {
		bprint("блуе team won the level with ");
		s = ftos(teamscr2);
		bprint(s);
		bprint(" points!\n");
		bprint("ред team lost with ");
		s = ftos(teamscr1);
		bprint(s);
		bprint(" points.\n");
	} else {
		bprint("блуе and ред team tied level with ");
		s = ftos(teamscr1);
		bprint(s);
		bprint(" points!\n");
	}
};

string(entity who) RuneName =
{
	if (who.player_flag & ITEM_RUNE1_FLAG)
		return "\nEarth/Resistance   ";
	if (who.player_flag & ITEM_RUNE2_FLAG)
		return "\nBlack/Strength     ";
	if (who.player_flag & ITEM_RUNE3_FLAG)
		return "\nHell/Haste         ";
	if (who.player_flag & ITEM_RUNE4_FLAG)
		return "\nElder/Regeneration ";
	return     "\n                   ";
};

void() TeamCapturePlayerUpdate =
{
	local string n;
	local string t;

	if (self.laststattime > time)
		return;

	TeamCaptureCheckUpdate();

	self.laststattime = time + PLAYERSTATTIME;

	if (self.motd_count) {
		if (self.observer)
			MOTD_ChooseTeam();
		else
			MOTD();
		return;
	}

	if (self.statoff)
		return;

	if (gamestart) {
		if (vote_leader == world)
			centerprint(self, "\n\n\n\n\n\n\n\n\n\n\n\n                    Choose an exit...");
		else {
			n = ftos(voteexit_time - time);
			centerprint5(self, "\n\n\n\n\n\n\n\n\n\n\n", vote_leader.message,
				" leads\n", n, " seconds until exit");
		}
		return;
	}

	t = RuneName(self);
	if (teamscr1 == 0 && teamscr2 == 0) {
		centerprint3(self, "\n\n\n\n\n\n\n\n\n\n\n", t, "  Capture The Flag");
		return;
	}

	if (teamscr1 > teamscr2) {
		n = ftos(teamscr1 - teamscr2);
		centerprint4(self, "\n\n\n\n\n\n\n\n\n\n\n", t, "           RED ", n);
	} else if (teamscr1 < teamscr2) {
		n = ftos(teamscr2 - teamscr1);
		centerprint4(self, "\n\n\n\n\n\n\n\n\n\n\n", t, "          BLUE ", n);
	} else {
		centerprint3(self, "\n\n\n\n\n\n\n\n\n\n\n", t, "          TIED");
		return;
	}
};

void(entity who, string s) TeamPlayerUpdate =
{
	local string n;
	local string t;

	TeamCaptureCheckUpdate();
	who.laststattime = time + PLAYERSTATTIME;

	if (self.statoff) {
		centerprint2(who, "\n\n\n\n\n\n\n\n\n\n\n", s);
		return;
	}

	t = RuneName(who);
	if (teamscr1 == 0 && teamscr2 == 0) {
		centerprint4(who, "\n\n\n\n\n\n\n\n\n\n\n", s, t, "  Capture The Flag");
	} else if (teamscr1 > teamscr2) {
		n = ftos(teamscr1 - teamscr2);
		centerprint5(who, "\n\n\n\n\n\n\n\n\n\n\n", s, t, "           RED ", n);
	} else if (teamscr1 < teamscr2) {
		n = ftos(teamscr2 - teamscr1);
		centerprint5(who, "\n\n\n\n\n\n\n\n\n\n\n", s, t, "          BLUE ", n);
	} else
		centerprint4(who, "\n\n\n\n\n\n\n\n\n\n\n", s, t, "          TIED");
};

void(entity who, string s1, string s2) TeamPlayerUpdate2 =
{
	local string n;
	local string t;

	TeamCaptureCheckUpdate();
	who.laststattime = time + PLAYERSTATTIME;

	if (self.statoff) {
		centerprint3(who, "\n\n\n\n\n\n\n\n\n\n\n", s1, s2);
		return;
	}

	t = RuneName(who);
	if (teamscr1 == 0 && teamscr2 == 0) {
		centerprint5(who, "\n\n\n\n\n\n\n\n\n\n\n", s1, s2, t, " Capture The Flag");
		return;
	} else if (teamscr1 > teamscr2) {
		n = ftos(teamscr1 - teamscr2);
		centerprint6(who, "\n\n\n\n\n\n\n\n\n\n\n", s1, s2, t, "          RED ", n);
	} else if (teamscr1 < teamscr2) {
		n = ftos(teamscr2 - teamscr1);
		centerprint6(who, "\n\n\n\n\n\n\n\n\n\n\n", s1, s2, t, "          BLUE ", n);
	} else {
		centerprint5(who, "\n\n\n\n\n\n\n\n\n\n\n", s1, s2, t, "          TIED");
		return;
	}
};

