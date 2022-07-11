// *****************************************************************
//  Pure CTF v1.52beta15 by Dan "Methabol" Zetterstrˆm 1998-07-??
//  Pure CTF Homepage: http://purectf.solgames.com/
//  Report bugs and ideas to: methabol@hem.passagen.se
// *****************************************************************

// =================
//     CONSTANTS
// =================
float TEAM_COLOR1       =       4;
float TEAM_COLOR2       =       13;
float FLAG_TOSSED = 4;

// =================
//     VARIABLES
// =================
float nexttimercheck;			// Next Time to write countdowntimer
float GLOBAL_UPDATE;			// Time set for global update
float paused;				// obsolete?
float READY, NOTREADY;			// Number of players ready and not ready
float blink;				// Blink hack
float blinktime;			// Blink hack
float RED_PICKUP, BLUE_PICKUP; 		// Timing captures
	// <--
float lastred, lastblue;		// **debug ->> obsolete?
float teamscr1;				// team 1's teamscr score
float teamscr2;				// team 2's teamscr score
string motd1, motd2, motd3, motd4, motd5, motd6, motdred, motdblue, motdexit;
// obsolete? entity SpawnChain;			

// =================
//      FIELDS  
// =================


// =================
//     FUNCTIONS
// =================
void() SpawnCTFMaps;


void(string newmap) ChangeMap = {
	local float x;
	bprint(PRINT_HIGH, "Next map is: ");
	bprint(PRINT_HIGH, newmap);
	x = cvar("samelevel");
	if (FLAG_VOTEEXIT && (x != 1) && !FLAG_COMPETITION) {
		bprint(PRINT_HIGH, " Type ÷œ‘≈≈ÿ…‘ to skip this map.");
	}
	bprint(PRINT_HIGH, "\n");
	changelevel(newmap);
};


void() RestartSameMap = {
	// *check* gˆr en delay och check
	bprint(PRINT_HIGH, "\nDetected changes, restarting map\n");
	ChangeMap(mapname);
};


void() tagline = {
	sprint(self, PRINT_HIGH, " –’“≈ √‘∆ ˆ±Æµ≤‚ÂÙ·±µ ‚˘ ÕÂÙË·‚ÔÏ\n http://purectf.solgames.com/\n");
};

void(entity pl, void() func) WithSelf = {
        local entity e;
        e = self;
        self = pl;
        func();
        self = e;
};

/*
=========
PrintRight

Prints a num, right aligned, to self.
=========
*/
void(entity e, float x) PrintRight = {
	local string tmp;
	tmp = ftos(x);
	if (x < 10000) sprint(e, PRINT_HIGH, " ");
	if (x < 1000)  sprint(e, PRINT_HIGH, " ");
	if (x < 100)   sprint(e, PRINT_HIGH, " ");
	if (x < 10)    sprint(e, PRINT_HIGH, " ");
	if (x = 0)     sprint(e, PRINT_HIGH, "0");
	sprint(e, PRINT_HIGH, tmp);
};

float (entity pl) IsClassPlayer = {
        if (pl.classname == "player")
                return 1;
        if (pl.classname == "ready")
                return 1;
        if (pl.classname == "notready")
                return 1;
        if (pl.classname == "observer")
                return 1;
        return 0;

};      

float (entity pl) IsClient = {
        if (pl.classname == "player")
                return 1;
	if (pl.classname == "observer")
		return 1;
        if (pl.classname == "spectator")
                return 1;
        if (pl.classname == "ready")
                return 1;
        if (pl.classname == "notready")
                return 1;
        return 0;
};


/*
==========
sPrintRight

Prints numbers formatted with a character to a player.
==========
*/
void(entity pl, float x, float digits, string ch) sPrintRight = {
	local string tmp;
	if ((digits > 6) && (x < 1000000)) sprint(pl, PRINT_HIGH, ch);
	if ((digits > 5) && (x < 100000)) sprint(pl, PRINT_HIGH, ch);
	if ((digits > 4) && (x < 10000)) sprint(pl, PRINT_HIGH, ch);
	if ((digits > 3) && (x < 1000)) sprint(pl, PRINT_HIGH, ch);
	if ((digits > 2) && (x < 100)) sprint(pl, PRINT_HIGH, ch);
	if (x >= 0)
		if ((digits > 1) && (x < 10)) sprint(pl, PRINT_HIGH, ch);
	
	tmp=ftos(x);
	if (x) 
		sprint(pl, PRINT_HIGH, tmp);
	else
		sprint(pl, PRINT_HIGH, "0");
};



void(float x, float digits, string ch) bPrintRight = {
	local string tmp;
	if ((digits > 6) && (x < 1000000)) bprint(PRINT_HIGH, ch);
	if ((digits > 5) && (x < 100000)) bprint(PRINT_HIGH, ch);
	if ((digits > 4) && (x < 10000)) bprint(PRINT_HIGH, ch);
	if ((digits > 3) && (x < 1000)) bprint(PRINT_HIGH, ch);
	if ((digits > 2) && (x < 100)) bprint(PRINT_HIGH, ch);
	if (x >= 0)
		if ((digits > 1) && (x < 10)) bprint(PRINT_HIGH, ch);
	
	tmp=ftos(x);
	if (x) 
		bprint(PRINT_HIGH, tmp);
	else
		bprint(PRINT_HIGH, "0");
};


void(entity pl, float x) PrintTime = {
	local float min, sec;
	local string tp;

	min = floor(x / 60);
	sec = floor(x - min * 60);
	
	sPrintRight(pl, min, 1, "0");
	sprint(pl, PRINT_HIGH, ":");
	sPrintRight(pl, sec, 2, "0");
};

void(float x) PrintTime2All = {
	local float min, sec;
	local string tp;

	min = floor(x / 60);
	sec = floor(x - min * 60);
	
	bPrintRight(min, 1, "0");
	bprint(PRINT_HIGH, ":");
	bPrintRight(sec, 2, "0");
};



void(entity pl) StuffRandomnum = {
	local float x;
	local string tp;
	x = floor(10 * random());
	tp = ftos(x);
	stuffcmd(pl, tp);
};

/*
=========
AutoDemo

Starts a demo at matchstart for the players who turned it on.
=========
*/
void() AutoDemo = {
	local entity e;
	local float no;
	local string tp;

	e = CLIENT_CHAIN;

	while (e) {
                if ((e.pure & 64) || (e.pure & 32)){
                        if ((e.pure & 32) && HaveProxy(e)) {
				stuffcmd(e, "say proxy: record ");	
			} else {
				stuffcmd(e, "record ");
			}
			stuffcmd(e, "auto");
			StuffRandomnum(e);
			StuffRandomnum(e);
			StuffRandomnum(e);
			StuffRandomnum(e);
			stuffcmd(e, "\n");
		}
		e = e.clientchain;
	}
};


void() StopDemos = {
	local entity e;
	local float no;
	local string tp;

	if (!FLAG_COMPETITION)
		return;

	e = CLIENT_CHAIN;
	while (e) {
		if ((e.pure & 64) || (e.pure & 32)) {
			if ((e.pure & 32) && HaveProxy(e)) {
				stuffcmd(e, "say proxy: record stop\n");	
			} else {
				stuffcmd(e, "stop\n");
			}	
		}
		if ((e.pure & 16) && !FLAG_STANDBY) 
			stuffcmd(e, "+showteamscores;wait;screenshot;wait;-showteamscores\n");
		e = e.clientchain;
	}
};

void() StopDemosThink = {
	local entity e;
	StopDemos();
	remove(self);
};


void() SetAutoShot = {
	if (self.pure & 16) {
		sprint(self, PRINT_HIGH, "Autoshot disabled\n");	
		self.pure = self.pure - 16;
	} else {
		sprint(self, PRINT_HIGH, "Autoshot enabled.\n");
		self.pure = self.pure | 16;
	}
	SetPureFlags(self);
	PrintNewPlayerSettings();
};

void() SetAutoDemo = {
	local string tp;

	if (self.pure & 32) {
		sprint(self, PRINT_HIGH, "Autodemo with QW:s recording.");	
		if (stof(infokey(world, "*version")) < 2.20) {
			sprint(self, PRINT_HIGH, " Note, this version of QW doesn't support this.");
		}
		sprint(self, PRINT_HIGH, "\n");	
		self.pure = (self.pure | 64) - (self.pure & 32);
	} else if (self.pure & 64) {
		sprint(self, PRINT_HIGH, "Autodemo off\n");	
		self.pure = self.pure - (self.pure & (64 | 32));
	} else {
		sprint(self, PRINT_HIGH, "Autodemo with Proxy. ");
		if (!HaveProxy(self))
			sprint(self, PRINT_HIGH, "(You don't have a demo proxy!)");
		sprint(self, PRINT_HIGH, "\n");
		self.pure = (self.pure | 32) - (self.pure & 64);
	}

	SetPureFlags(self);
	PrintNewPlayerSettings();
};



void(string tp, float x) PrintOnOff = {
	sprint(self, PRINT_HIGH, tp);
	if (x) sprint(self, PRINT_HIGH, "ON ");
	else sprint(self, PRINT_HIGH, "OFF");
};

void(string tp, float x) PrintSetting = {
	sprint(self, PRINT_HIGH, tp);
	sPrintRight(self, x, 3, " "); 
};

void(string tp, float x) PrintSettingOff = {
	sprint(self, PRINT_HIGH, tp);

	if (x) sPrintRight(self, x, 3, " "); 
	else sprint(self, PRINT_HIGH, "---");
};	


void(string tp, float x) PrintPureopt = {
	sprint(self, PRINT_HIGH, tp);
	if (x == IS_PURE)
		sprint(self, PRINT_HIGH, "ON ");	
	else if (x == IS_OFF)
		sprint(self, PRINT_HIGH, "OFF");	
	else if (x == IS_OLD)
		sprint(self, PRINT_HIGH, "OLD");	

};



void() sprintbreak = {
	sprint(self, PRINT_HIGH, "\n");
};

void() PrintSettings = {
	local float a,b,c,d,e,f,g, h;
	local string tp1;

	a = cvar("sv_maxspeed");
	b = FLAG_ANKAMAPS;
	c = ceil(TIMELIMIT / 60);
	d = cvar("sv_friction");
	tp1 = infokey(world , "mode");
	f = cvar("maxspectators");
	g = cvar("sv_spectalk");

	h = stof(infokey(world, "fpd"));

	sprint(self, PRINT_HIGH, "-----------------------------------");

	sprintbreak();
	

	sprint(self, PRINT_HIGH, "”ÂÚˆÂÚÌÔ‰Â : ");
	sprint(self, PRINT_HIGH, tp1);


	sprintbreak();

	PrintOnOff  (  "‘ÔÛÛÚıÓÂ   :", FLAG_TOSSRUNE);
	PrintOnOff  ("  ‘ÔÛÛÊÏ·Á   :", FLAG_TOSSFLAG);

	sprintbreak();

	sprint(self, PRINT_HIGH, "–Ô˜ÂÚıÛ   :");
	if (VAR_DISABLEPOWERUPS & BIT_NOQUAD) sprint(self, PRINT_HIGH, "-");
	else sprint(self, PRINT_HIGH, "Q");
	if (VAR_DISABLEPOWERUPS & BIT_NOPENTA) sprint(self, PRINT_HIGH, "-");
	else sprint(self, PRINT_HIGH, "P");
	if (VAR_DISABLEPOWERUPS & BIT_NORING) sprint(self, PRINT_HIGH, "-");
	else sprint(self, PRINT_HIGH, "R");

	sprint(self, PRINT_HIGH, "  –ÚÔ¯˘      :");
	
	if (h & 1) sprint(self, PRINT_HIGH, "-"); else sprint(self, PRINT_HIGH, "L");
	if (h & 2) sprint(self, PRINT_HIGH, "-"); else sprint(self, PRINT_HIGH, "T");
	if (h & 4) sprint(self, PRINT_HIGH, "-"); else sprint(self, PRINT_HIGH, "S");
	if (h & 8) sprint(self, PRINT_HIGH, "-"); else sprint(self, PRINT_HIGH, "L");
	

	sprintbreak();
	PrintSettingOff(  "‘ÈÌÂÏÈÌÈÙ  :", c);
	PrintSettingOff("  ÊÚ·ÁÏÈÌÈÙ  :", FRAGLIMIT);

	sprintbreak();
	PrintSetting(  "ƒÂ·ÙËÌ·Ù„Ë :", DEATHMATCH);
	PrintOnOff  ("  ¡ÓÎ· Õ·Û  :", b);
	
	sprintbreak();
	PrintOnOff  (  "ƒÚÔÚÈÓÁ   :", FLAG_DROPRING);
	PrintOnOff  ("  ƒÚÔÒı·‰   :", FLAG_DROPQUAD);

	sprintbreak();
	PrintPureopt(  "ƒÈÛ„Ë·ÚÁÂÛ :", SET_DISCHARGE);
	PrintPureopt("  “ıÓÂÛ      :", SET_RUNES);

	sprintbreak();
	PrintPureopt(  "»ÔÔÎ       :", SET_HOOK);
	PrintSetting("  »ÔÔÎÛÂÂ‰  :", HOOKSPEED);

	sprintbreak();
	PrintSetting(  "Õ·¯ÛÂÂ‰   :", a);
	PrintSetting("  ∆ÚÈ„ÙÈÔÓ   :", d);
	
	sprintbreak();
	PrintSetting(  "Õ·¯ÛÂ„Û   :", f);
	PrintOnOff  ("  ”Â„Ù·ÏÎ   :", g);
		
	
	sprint(self, PRINT_HIGH, "\n-----------------------------------\n");
};

// ***update*** <--

/*
===========
TimeLeft

Prints time left to a player.
===========
*/
void(entity pl) TimeLeft = {
	local float tmlim;
	if (FLAG_STANDBY)
		tmlim = 0;
	else if (FREEZEFLAGS & 1)
		tmlim = ceil(TIMELIMIT + MatchStartTime - FREEZETIME);
	else
		tmlim = ceil(TIMELIMIT + MatchStartTime - time);
	PrintTime(pl, tmlim);
};


/*
===========
MatchTime

Prints Match Time to a player.
===========
*/
void(entity pl) MatchTime = {
	local float tmlim;
	if (FLAG_STANDBY)
		tmlim = 0;
	else 
		tmlim = floor(time - MatchStartTime);
	PrintTime(pl, tmlim);
};

void() MatchTime2All = {
	local float tmlim;
	if (FLAG_STANDBY)
		tmlim = 0;
	else 
		tmlim = floor(time - MatchStartTime);
	PrintTime2All(tmlim);
};



/*
==========
MapqueueStatus

Prints the mapqueue into serverinfo
==========
*/
void() MapqueueStatus = {
	local float x, slev;
	local string map1, map2;


        if (!FLAG_COMPETITION) {
		localcmd("serverinfo mapqueue \"\"\n");
		return;
	}
	
	slev = cvar("samelevel");
	if (slev == 0) {
		localcmd("serverinfo mapqueue \"Episode Vote\"\n");
	} else if (slev == 1) {
		localcmd("serverinfo mapqueue \"Samelevel\"\n");
	} else if (slev == 2) {
		x = 0;
		map1 = infokey(world, mapname);
		localcmd("serverinfo mapqueue \"");
		while ((map1 != mapname) && (map1 != "") && (x < 8)) {
			localcmd(map1);
			localcmd(" ");
			map1 = infokey(world, map1);
			x = x + 1;
		}
		localcmd(mapname);
		localcmd("\"\n");
		if (map1 == "") 
			localcmd("serverinfo mapqueue \"*BROKEN*\"\n");
	} else if (slev == 3) {
		localcmd("serverinfo mapqueue \"Random\"\n");
	}
};

void() PrintMapqueue = {
	local float x, slev;
	local string map1, map2;
	
	slev = cvar("samelevel");

	if (slev == 0) {
		sprint(self, PRINT_HIGH, "Mapqueue is Episode Vote\n");
	} else if (slev == 1) {
		sprint(self, PRINT_HIGH, "Mapqueue is SAMELEVEL\n");
	} else if (slev == 2) {
		x = 0;
		map1 = infokey(world, mapname);
		sprint(self, PRINT_HIGH, "Õ·ÒıÂıÂ: ");
		while ((map1 != mapname) && (map1 != "") && (x < 50)) {
			sprint(self, PRINT_HIGH, map1);
			sprint(self, PRINT_HIGH, " ");
			map1 = infokey(world, map1);
			x = x + 1;
		}
		sprint(self, PRINT_HIGH, mapname);
		sprint(self, PRINT_HIGH, "\n");
		if ((x == 50) || (map1 == "")) 
			sprint(self, PRINT_HIGH, "Mapqueue is BROKEN\n");
	} else if (slev == 3) {
		sprint(self, PRINT_HIGH, "Random Mapqueue\n");
	}
};




/*
==========
UpdateClientChain

Updates the Client and Player chains.
==========
*/
void() UpdateClientChain = {
	local entity e;
	local entity ch;
	local entity ch_start, pl_start;

	ch = spawn();
	ch_start = ch;
	e = find(world, classname, "spectator");
	while(e) {
		if (!(e.player_flag & PF_GHOST)) {
			ch.clientchain = e;
			ch = e;
		}
		e = find(e, classname, "spectator");
	}
	pl_start = ch;
	e = find(world, classname, "player");
	while(e) {
		if (!(e.player_flag & PF_GHOST)) {
			ch.clientchain = e;
			ch = e;
		}
		e = find(e, classname, "player");
	}
	e = find(world, classname, "ready");
	while(e) {
		if (!(e.player_flag & PF_GHOST)) {
			ch.clientchain = e;
			ch = e;
		}
		e = find(e, classname, "ready");
	}
	e = find(world, classname, "notready");
	while(e) {
		if (!(e.player_flag & PF_GHOST)) {
			ch.clientchain = e;
			ch = e;
		}
		e = find(e, classname, "notready");
	}
	e = find(world, classname, "observer");
	while(e) {
		if (!(e.player_flag & PF_GHOST)) {
			ch.clientchain = e;
			ch = e;
		}
		e = find(e, classname, "observer");
	}
	ch.clientchain = world;

	CLIENT_CHAIN = ch_start.clientchain;
	PLAYER_CHAIN = pl_start.clientchain;
	remove(ch_start);

	// Count players here.
	TEAM1 = 0;
	TEAM2 = 0;
	TOTALPLAYERS = 0;

	e = PLAYER_CHAIN;
	while(e) {
		if ((TEAMPLAY & 32) && (self.classname != "observer")) {
			if ((e.steam == TEAM_COLOR1))		
				TEAM1 = TEAM1 + 1;		
			else if ((e.steam == TEAM_COLOR2))	
				TEAM2 = TEAM2 + 1;
		}		
		TOTALPLAYERS = TOTALPLAYERS + 1;
		e = e.clientchain;
	}
};




void(void(entity x) fun) TraversePlayers = {
	local entity e;
	e = PLAYER_CHAIN;
	while(e) {
		fun(e);
		e = e.clientchain;
	}
};

void(void(entity x) fun) TraverseClients = {
	local entity e;
	e = PLAYER_CHAIN;
	while(e) {
		fun(e);
		e = e.clientchain;
	}
};

void() revertthink = {
	local float x;
	if (TOTALPLAYERS == 0) {
		bprint(PRINT_HIGH, "Reverting to standard mode.\n");
		x = localinfo("mode", 0);
		x = x - (x & (1));
		SetVar(1, "mode", x);
		ShowdownDefault();
	}
	remove(self);
};




void() EmptyServer = {
	local entity e;
	local string tp;
	if (FLAG_DEBUG)
		bprint(PRINT_HIGH, "Server is empty, restoring settings..\n");
	if (FLAG_COMPETITION && REVERTTOSTANDARD) {
		e = spawn();
		e.think = revertthink;
		e.nextthink = time + (REVERTTOSTANDARD * 60);
	}
	
	tp = infokey(world, "default_maxspecs");
	if (stof(tp)) 
		cvar_set("maxspectators", tp);
};


// ***commands*** -->




void() makecounter;


// debug -->

void() cyclered;
void() cycleblue;
void() dumpstarts;
void (vector org, float fteam, float angl) SpawnTeamStart;
float NEWFLAG;

// debug <--


float() CheckAdminInput;


// ***commands*** <--


// ***statbar*** -->

void() SetStatusBar = {
	local float  temp;
	temp = (self.impulse - 70) & 15;

	self.pure = self.pure - (self.pure & 15) + temp;
	sprint(self, PRINT_HIGH, "Status bar set\n");

	SetPureFlags(self);
	PrintNewPlayerSettings();
};

void() SwapStatusBar = {
	self.pure = self.pure - (self.pure & 15);
	sprint(self, PRINT_HIGH, "Status bar off.\n");
	SetPureFlags(self);
	PrintNewPlayerSettings();
};
// ***statbar*** <--


void(float x) printnum = {
	local string tmp;
	if (x)
		tmp = ftos(x);
	else
		tmp = "0";
	bprint(PRINT_HIGH, tmp);
};



// ***timer*** -->
void(string tp) soundall = {
	local entity e;
	e = CLIENT_CHAIN;
	while (e) {
		sound(e, CHAN_AUTO, tp , 1, ATTN_IDLE); 
		e = e.clientchain;
	}
};

// *check* inline?
void(entity pl) RemoveCenterprint = {
	centerprint(pl, " ");
};

// *check* move to printing?
void(float tlimit) OutputTimer = {
	local float timeleft, min, sec;
	local entity e;
	local string tmp;

	if (!tlimit)
		return;
	if (time < nexttimercheck) 
		return;

	timeleft =  ceil(tlimit - time);
	if (CountDown) {
		TraversePlayers(PrintCountDown);
	} else if (timeleft >= 60) {
		min =  ceil(timeleft / 60);
		tmp=ftos(min);
		bprint(PRINT_MEDIUM, tmp);
		if (min == 1)
			bprint(PRINT_MEDIUM, " minute left\n");
		else
			bprint(PRINT_MEDIUM, " minutes left\n");
	} else if (timeleft >= 10) {
		sec = timeleft;
		sec = ceil(sec);
		tmp = ftos(sec);
		bprint(PRINT_MEDIUM, tmp);
		bprint(PRINT_MEDIUM, " seconds left\n");
	} else {
		sec = timeleft;
		if (FLAG_RASOUNDS) {
			if (sec == 1) soundall("ra/1.wav"); 
			if (sec == 2) soundall("ra/2.wav"); 
			if (sec == 3) soundall("ra/3.wav"); 
		}
		tmp=ftos(sec);
		if (timeleft < 0) 
			tmp = "0";
		bprint(PRINT_MEDIUM, tmp);
		bprint(PRINT_MEDIUM, "\n");
	}
	timeleft = timeleft - 0.1;
	if (CountDown)
		nexttimercheck = floor(time + 1);
	else if (timeleft > 300)
		nexttimercheck = tlimit - (floor(timeleft / 300) * 300);
	else if (timeleft > 60)
		nexttimercheck = tlimit - (floor(timeleft / 60) * 60);
	else if (timeleft > 30)
		nexttimercheck = tlimit - (floor(timeleft / 30) * 30);
	else if (timeleft > 10)
		nexttimercheck = tlimit - (floor(timeleft / 10) * 10);
	else if (timeleft > 5)
		nexttimercheck = tlimit - (floor(timeleft / 5) * 5);
	else if (timeleft > 0)
		nexttimercheck = tlimit - floor(timeleft);
	
};
// ***timer*** <--


// ***comp*** -->



void() UpdateRandomSeed = {
	local float x;
	local string tp;

	x = stof(infokey(world, "randomseed"));
	if (!x) x = 50;
	while(x) {
		random();	
		x = x - 1;
	}
	x = ceil(random() * 50);
	tp = ftos(x);	
	localcmd("localinfo randomseed ");
	localcmd(tp);
	localcmd("\n");
};


void() UnstuffSpectator = {
	stuffcmd(self, "bind 1 \"impulse 1\"\n");
	stuffcmd(self, "bind 2 \"impulse 2\"\n");
	stuffcmd(self, "bind 3 \"impulse 3\"\n");
	stuffcmd(self, "bind 4 \"impulse 4\"\n");
	stuffcmd(self, "bind 5 \"impulse 5\"\n");
	stuffcmd(self, "bind 6 \"impulse 6\"\n");
	stuffcmd(self, "bind 7 \"impulse 7\"\n");
	stuffcmd(self, "bind 8 \"impulse 8\"\n");
	unsetinfo(self, "sb");
};






void() CheckRate = {
	local string tp;
	local float rate;
	rate = stof(infokey(self, "rate"));

	if (PLAYER_MAXRATE && (rate > PLAYER_MAXRATE))
		if (IsClassPlayer(self))
			setinfo(self, "rate", PLAYER_MAXRATE);
	if (PLAYER_MINRATE && (rate < PLAYER_MINRATE))
		if (IsClassPlayer(self))
			setinfo(self, "rate", PLAYER_MINRATE);
	if (SPEC_MAXRATE && (rate > SPEC_MAXRATE))
		if (self.classname == "spectator")
			setinfo(self, "rate", PLAYER_MINRATE);
};



void() CheckPing;

void() PeriodicCheck = {
	local float rp;
	
	if ((self.lastupdate > time) && (GLOBAL_UPDATE == self.lastglobalupdate)) 
		return;

	self.lastglobalupdate = GLOBAL_UPDATE;

	if (time < 10) 	rp = random();
	else 		rp = 0.9;	
	if (FLAG_STANDBY || STARTDELAY)		self.lastupdate = time + rp;
	else 					self.lastupdate = time + rp + 0.75;

	TeamCheckLock();
	CheckPing();

	TeamCapturePlayerUpdate();

	CheckMapChange();
	CheckAdmin();
	CheckRate();
	CheckStuffings();
};



void() StartAfterDelay = {
	UnFreeze(31);
	bprint(PRINT_HIGH, "Game has started!\n");
	MatchStartTime = floor(time);
};

void() PureInitMap = {

	ForceUpdateVariables();
	UpdateRandomSeed();
	SpawnCTFMaps();

	ResetPingBans();

	// Restore maxclients value if needed
	RestoreMaxClients();
	
	// Update Serverinfo
	localcmd("serverinfo purectf \"v1.52beta15\"\n");
	MapqueueStatus();
	SaveDefaults();

	RESTART = stof(infokey(world, "restart"));
	localcmd("localinfo restart \"\"\n");
	if (RESTART) {
		Freeze(26);
		forceready = 1;
	}

	STARTDELAY = stof(infokey(world, "startdelay"));	
	if (FLAG_COMPETITION)
		STARTDELAY = 0;
	if (STARTDELAY) {
		Freeze(26);
		StartCountDown(STARTDELAY, StartAfterDelay, "‘ËÂ Á·ÌÂ ˜ÈÏÏ ÛÙ·ÚÙ\n ·ÊÙÂÚ ÙËÂ „ÔıÓÙ‰Ô˜Ó\n\n");
	}

	localcmd("localinfo superadmin 0\n");

	SetTeamParameters();


	if (!localinfo("force_sv_gamedir",0)) {
		if (IsCTFMap())
			localcmd("sv_gamedir ctf\n");
		else if (IsArenamap())
			localcmd("sv_gamedir arena\n");
		else if (FLAG_CTF)
			localcmd("sv_gamedir ctf\n");
		else if (FLAG_ARENA)
			localcmd("sv_gamedir arena\n");
		else 	
		localcmd("sv_gamedir qw\n");
	}

	if (FLAG_DEBUG) {
		bprint(PRINT_HIGH, "\n***********************************\n");
		bprint(PRINT_HIGH, "SERVER IS RUNNING IN DEBUG MODE!   \n");
		bprint(PRINT_HIGH, "\"serverinfo debug 0\" to turn off.\n");
		bprint(PRINT_HIGH, "***********************************\n\n");
	}
	// Store current map.
	local float mapqflag;
	mapqflag = localinfo("mapqflag", 0);
	if (mapqflag == 1) {
		localcmd("localinfo mapq1 ");
		localcmd(mapname);
		localcmd("\n");
	} else if (mapqflag == 2) {
		localcmd("localinfo mapq2 ");
		localcmd(mapname);
		localcmd("\n");
	}
	localcmd("localinfo mapqflag 0\n");

	GSLogStart();					// GSLOG
};




// <-- check
