
float voteexit_time;
entity vote_leader;		// current leader
entity lastvotespawn;

void(vector org) spawn_tfog;
void(vector org, entity death_owner) spawn_tdeath;
void() InitTrigger;

/*QUAKED info_vote_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a voteexit.  It should have a "targetname" 
field with the same value as a voteexit's "target" field.
*/
void() info_vote_destination =
{
	// this does nothing, just serves as a target spot
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = "";
	self.origin = self.origin + '0 0 27';
	if (!self.targetname)
		objerror ("no targetname");
};

void() voteexit_teleport =
{
local entity	t;
local vector	org;

// put a tfog where the player was
	spawn_tfog (other.origin);

// if we aren't in custom mode, just find a deathmatch target
	// find the destination 
	if (!self.target) {
		lastvotespawn = find(lastvotespawn, classname, "info_player_deathmatch");
		if (lastvotespawn == world)
			lastvotespawn = find (lastvotespawn, classname, "info_player_deathmatch");
		t = lastvotespawn;
	} else
		t = find (world, targetname, self.target);

	if (!t)
		objerror ("couldn't find target");
		
// spawn a tfog flash in front of the destination
	makevectors (t.mangle);
	org = t.origin + 32 * v_forward;

	spawn_tfog (org);
	spawn_tdeath(t.origin, other);

// move the player and lock him down for a little while
	if (!other.health)
	{
		other.origin = t.origin;
		other.velocity = (v_forward * other.velocity_x) + (v_forward * other.velocity_y);
		return;
	}
	setorigin (other, t.origin);
	other.angles = t.mangle;

	other.fixangle = 1;		// turn this way immediately
	other.teleport_time = time + 0.7;

	if (other.flags & FL_ONGROUND)
		other.flags = other.flags - FL_ONGROUND;
	other.velocity = v_forward * 300;
};

void() voteexit_touch =
{
local entity	t;

	if (other.classname != "player")
		return;

// only teleport living creatures
	if (other.health <= 0 || other.solid != SOLID_SLIDEBOX)
		return;

	if (other.voted) {
		if (other.voted < time)
			PrintStatusbar(other, "You have already voted.",1);
		other.voted = time + 1;
		voteexit_teleport();
		return;
	}

	// non-zero for vote, time is when to display a 'you voted' msg
	other.voted = time + 1;

	SUB_UseTargets ();

	bprint(PRINT_HIGH, other.netname);
	bprint(PRINT_HIGH, " has voted for ");
	bprint(PRINT_HIGH, self.message);
	bprint(PRINT_HIGH, "\n");

// ok, the player has voted for this exit
	self.cnt = self.cnt + 1;

	// find new leader
	// we're on the start map, something special is happening
	vote_leader = world;
	t = find(world, classname, "trigger_voteexit");
	while (t != world) {
		if ((t.cnt > vote_leader.cnt) && (t != self))
			vote_leader = t;
		t = find(t, classname, "trigger_voteexit");
	}
	// if we are higher than the current leader, then we are the new
	// leader, if we are same, half chance
	if (self.cnt > vote_leader.cnt)
		vote_leader = self;
	else if ((self.cnt == vote_leader.cnt) && (random() > 0.5))
		vote_leader = self;

	// we check here about exit time
	if (vote_leader != world && voteexit_time == 0)
		voteexit_time = time + VOTEEXIT_TIME_LIMIT;

	// notify everyone about the change
	TeamCaptureResetUpdate();

	voteexit_teleport();
};

/*QUAKED trigger_voteexit (.5 .5 .5) ?
A merge of trigger_change level and trigger_teleport.  A player touching
this this teleported just like a trigger_teleport, except this triggers
.cnt field gets incremented.  This allows players to vote for their exit.
See status.qc for the display and total of the voting.
Any object touching this will be transported to the corresponding 
info_vote_destination entity. You must set the "target" field, and 
create an object with a "targetname" field that matches.
*/
void() trigger_voteexit =
{
	local vector o;

	InitTrigger ();
	self.touch = voteexit_touch;
	self.cnt = 0;
};

// *check*
