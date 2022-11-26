//Kasuha's DeathMatch Camera patch version 2.0

// KasCam variables

.vector CamPos;       // Current expected camera position
.entity CamTargEnt;   // Targeted entity
.vector CamTarget;    // Current expected targeted point
.vector CamTargAim;   // Aiming point
.float CamSpeed;     // Force pulling the camera to ideal position
.float CamCut;       // TRUE if camera has to jump to destination
.float CamDist;      // Max distance for flyby mode
.float CamMsgs;      // "take" messages ON/OFF
.float CamState;     // Camera state
.float Camnextthink;  // Delay measure
.float Camforceidle;     // How long to keep looking at dead body

// KasCam constants

float CAM_NOT       = 0;   // Not a camera
float CAM_PREBECOME = 1;   // Become a camera
float CAM_BECOME    = 2;   // Become a camera
float CAM_IDLE      = 3;   // Camera idle, nobody to look at
float CAM_FLYBY     = 4;   // Fly-by camera
float CAM_FOLLOW    = 5;   // Camera following a player

// KasCam functions

void() InitCamClient;
void() CamThink;
float() DoObserverImpulse;
void() CheckAdminCmd;

float(float num) sign =
{
    if (num>0)
        return 1;
    else if (num<0)
        return -1;
    else
        return 0;
};

float(float adist, float vprev) ang_speed =
{
    local float sg;

    while (adist > 128)
        adist = adist - 256;
    while (adist < -128)
        adist = adist + 256;
    adist = floor(adist);
    sg = sign (adist);
    adist = fabs (adist);
    if (((vprev == 0) && (adist < 5)) || (adist < 2))
        adist = 0;
    else if (adist < 15)
        adist = 1;
    else
    {
        adist = (adist - 9) / 3;
        adist = floor(adist);
    }
    adist = adist * sg;
    return adist;
};

// Visibility test

float(vector vec) CamVisible =
{
    traceline(self.origin,vec,TRUE,self);
    return ((trace_fraction == 1) && !((trace_inopen && trace_inwater)));
};

float(entity ent) CamVisibleEnt =
{
    local vector vec;

// Three points: origin, bottom and eyes
    if (CamVisible(ent.origin))
        return TRUE;
    vec = ent.origin;
    vec_z = ent.absmin_z;
    if (CamVisible(vec))
        return TRUE;
    vec_z = ent.absmax_z - 8;
    return CamVisible(vec);
};

float(entity targ, vector vec) TryFlybyVector =
{
    local vector orig,vec1;
    local float vl;

    vec1 = normalize(vec);
    vec = 700 * vec1;
    orig = targ.origin;
    orig_z = targ.absmax_z - 8;
    traceline(orig,orig+vec,TRUE,self);
    if (trace_inopen && trace_inwater)
        return 1111;
    trace_endpos = trace_endpos - vec1;
    vl = vlen(targ.origin - trace_endpos);
    if (vl<50)
        return 1111;
    if (pointcontents(trace_endpos) == CONTENT_SOLID)
        return 1111;
    return fabs(333 - vl);
};

// FlyBy mode initialization
// Targeted player is in CamTargEnt

void(entity newtarg) InitFlybyMode =
{
    local float f, max;
    local vector vec, vec2;
    local entity ent;


// Keep camera at this point some time...
    self.Camnextthink = time + 0.3;

// Report selected player
    if (self.CamTargEnt!=newtarg)
    {
        if (self.CamMsgs)
        {
            bprint("Now tracking ");
            bprint(newtarg.netname);
            bprint(" with ");
            if (newtarg.frags < 0)
                bprint("[ahem] ");
            if (newtarg.frags < 1)
                bprint("no");
            else
                bprint(ftos(newtarg.frags));
            if (newtarg.frags!=1)
                bprint(" frags\n");
            else
                bprint(" frag\n");
        }
        self.CamTargEnt = newtarg;
    }
    vec = self.CamTargEnt.angles;
    vec_x = 0;
    makevectors (vec);
    v_forward = 3 * v_forward;

    max = 1000;
    f = TryFlybyVector(self.CamTargEnt, v_forward + v_up + v_right);
    if (f<max)
    {
        max = f;
        vec = trace_endpos;
    }
    f = TryFlybyVector(self.CamTargEnt, v_forward + v_up - v_right);
    if (f<max)
    {
        max = f;
        vec = trace_endpos;
    }
    f = TryFlybyVector(self.CamTargEnt, v_forward + v_right);
    if (f<max)
    {
        max = f;
        vec = trace_endpos;
    }
    f = TryFlybyVector(self.CamTargEnt, v_forward - v_right);
    if (f<max)
    {
        max = f;
        vec = trace_endpos;
    }
    f = TryFlybyVector(self.CamTargEnt, v_forward + v_up);
    if (f<max)
    {
        max = f;
        vec = trace_endpos;
    }
    f = TryFlybyVector(self.CamTargEnt, v_up - v_forward);
    if (f<max)
    {
        max = f;
        vec = trace_endpos;
    }
    f = TryFlybyVector(self.CamTargEnt, v_up + v_right - v_forward);
    if (f<max)
    {
        max = f;
        vec = trace_endpos;
    }
    f = TryFlybyVector(self.CamTargEnt, v_up - v_right - v_forward);
    if (f<max)
    {
        max = f;
        vec = trace_endpos;
    }
    if (max >= 1000)
    {
        self.CamState = CAM_IDLE;
        self.Camnextthink = time + 2;
        return;
    }
    self.CamTarget = self.CamTargEnt.origin;
    self.CamPos = vec;
    self.CamCut = TRUE;
    self.CamState = CAM_FLYBY;
    self.CamDist = 1.5 * vlen(self.CamPos - self.CamTarget);
    if (self.CamDist < 500)
        self.CamDist = 500;
};

vector() GetFollowCam =
{
    local vector vec, vec2;

    makevectors(self.CamTargEnt.v_angle);
    vec = self.CamTargEnt.origin + (self.CamTargEnt.maxs_z + 4) * v_up;
    traceline(self.CamTargEnt.origin,vec,FALSE,self);
    vec = trace_endpos - normalize(vec);
    vec2 = -100 * v_forward;
    traceline(vec,vec+vec2,TRUE,self);
    vec2 = trace_endpos - normalize(vec2);
    if (CamVisible(vec2))
        return vec2;
    else
        return vec;
};

vector() GetFollowTrg =
{
    local vector vec;

    makevectors(self.CamTargEnt.v_angle);
    vec = aim(self.CamTargEnt,100000);
    vec = self.CamTargEnt.origin + 2048 * vec;

    return vec;
};

// Impulse handling

void() CamImpulses =
{
    local float c;
    local entity ent;

	if (self.impulse && self.accessparm) { // admin functions
		CheckAdminCmd();
		self.impulse = 0;
	} else if ((self.impulse > 100) && (self.impulse < 200)) {
		// camera impulses

        c = self.impulse - 100;
        ent = world;
        do
        {
           ent = find(ent,classname,"player");
           c = c - 1;
        } while ((c>0) && (ent != world));
        if (ent != world)
        {
            if (ent.deadflag == DEAD_NO)
                InitFlybyMode(ent);
        }
    } else if ((self.impulse == 200) && (self.CamState != CAM_IDLE))
        InitFlybyMode(self.CamTargEnt);
    else if ((self.impulse == 201) && (self.CamState != CAM_IDLE))
        self.CamState = CAM_FOLLOW;
    else if (self.impulse == 210)
        self.CamMsgs = !self.CamMsgs;
	else if (DoObserverImpulse())
		return;
	else if (self.impulse)
		CheckAdminCmd();

    self.impulse = 0;
};

// Camera thinking routine
// Called every frame

void() CamThink =
{
    local vector vmove, vec;
    local float grad;
    local entity ent,ent2;
    local float it;
    local float p1,p2;
	local string s;

// I know this is terrible but I think that it is better to keep
// hooking points at the smallest possible count...
// I also think that the variable change increases the packet
// size so I test everything rather than only updating

    if (self.CamTargEnt.classname == "player")
    {
// Mask out items which change view color
        it = IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD;
        it = (self.CamTargEnt.items | it) - it;
        if (self.items != it)
            self.items = it;
        if (self.health != self.CamTargEnt.health)
// do not let the camera die or the view will rotate
            if (self.CamTargEnt.health>0)
                self.health = self.CamTargEnt.health;
            else if (self.health != 1)
                self.health = 1;
        if (self.armorvalue != self.CamTargEnt.armorvalue)
            self.armorvalue = self.CamTargEnt.armorvalue;
        if (self.ammo_shells != self.CamTargEnt.ammo_shells)
            self.ammo_shells = self.CamTargEnt.ammo_shells;
        if (self.ammo_nails != self.CamTargEnt.ammo_nails)
            self.ammo_nails = self.CamTargEnt.ammo_nails;
        if (self.ammo_rockets != self.CamTargEnt.ammo_rockets)
            self.ammo_rockets = self.CamTargEnt.ammo_rockets;
        if (self.ammo_cells != self.CamTargEnt.ammo_cells)
            self.ammo_cells = self.CamTargEnt.ammo_cells;
        if (self.weapon != self.CamTargEnt.weapon)
            self.weapon = self.CamTargEnt.weapon;
        if (self.currentammo != self.CamTargEnt.currentammo)
            self.currentammo = self.CamTargEnt.currentammo;
    }
    else
    {
        if (self.items != 0)
            self.items = 0;
        if (self.health != 100)
            self.health = 100;
        if (self.armorvalue != 0)
            self.armorvalue = 0;
        if (self.ammo_shells != 0)
            self.ammo_shells = 0;
        if (self.ammo_nails != 0)
            self.ammo_nails = 0;
        if (self.ammo_rockets != 0)
            self.ammo_rockets = 0;
        if (self.ammo_cells != 0)
            self.ammo_cells = 0;
        if (self.weapon != IT_AXE)
            self.weapon = IT_AXE;
        if (self.currentammo != 0)
            self.currentammo = 0;
    }

    if (self.CamState == CAM_IDLE)
    {
// Look for some players
// If nobody present, do idle movement
        ent = find (world, classname, "player");
        ent2 = self;
// find the most promising player
        if (self.Camforceidle < time)
        {
            while (ent != world)
            {
// Dead or dying are not interesting at this point
                if (ent.deadflag == DEAD_NO)
                {
                    if (ent2 == self)
                        ent2 = ent;
                    else if ((ent2.frags < ent.frags) || ((ent2.frags == ent.frags) && (ent2.health < ent.health)))
                        ent2 = ent;
                }
                ent = find (ent,classname,"player");
            }
        }
// If a interesting object found
        if (ent2 != self)
        {
// Go to FlyBy mode
            InitFlybyMode (ent2);
        }
        else
        {
// Idle moves
            self.CamTargEnt =  self;
            self.CamSpeed = 0.01;
            traceline(self.CamPos,self.CamTarget,TRUE,self);
            if (trace_fraction != 1)
                self.CamTarget = trace_endpos;
            if (self.Camnextthink < time)
            {
                self.Camnextthink = time + 0.5;
                vec_x = random () - 0.5;
                vec_y = random () - 0.5;
                vec_z = (random () - 0.5) / 10;
                vec = 2000 * normalize(vec);
                vec = self.CamPos + vec;
                traceline(self.CamPos, vec, TRUE, self);
                if (trace_fraction != 1)
                    vec = trace_endpos;

                p1 = vlen(vec - self.CamPos);
                p2 = vlen(self.CamTarget - self.CamPos);
                if (p1 > p2)
                {
                    self.CamTarget = vec;
                }
                else
                {
                    if (random() > 0.9)
                    {
                        self.CamPos = self.CamPos + 0.9 * (self.CamTarget -
							self.CamPos);
                    }
                }
            }
        }
    }
    else if (self.CamState == CAM_FLYBY)
    {
// self.CamTarget is set to player
// Check if the player is not dead
        if (self.CamTargEnt.deadflag == DEAD_RESPAWNABLE)
        {
// player is dead
// make camera idle so that it finds another good target
            self.CamState = CAM_IDLE;
            self.Camnextthink = time + 3;
            self.Camforceidle = time + 1;
            return;
        }
// All other restrictions apply after some time
// Test player visibility
// If player not visible place another camera
        p1 = vlen(self.CamPos - self.CamTargEnt.origin);
        if ((CamVisibleEnt(self.CamTargEnt) && (self.CamDist > p1)) ||
			(self.Camnextthink > time))
            self.CamTarget = self.CamTargEnt.origin;
        else
            InitFlybyMode (self.CamTargEnt);
// Check for FOLLOW mode change
// Player has to be near
// And looking away
// And the destination point must be visible
        p1 = vlen(self.CamTargEnt.origin - self.origin);
        if (p1 < 200)
        {
// Player is near enough
// Now if it points away
            grad = fabs(self.CamTargEnt.angles_y - self.angles_y);
            if (grad > 180)
                grad = 360 - grad;
            if (grad < 30)
            {
// Calculate following point
                vec = GetFollowCam();
                if (CamVisible(vec))
                {
                    self.CamState = CAM_FOLLOW;
                }
            }
        }
    }
    else if (self.CamState == CAM_FOLLOW)
    {
        self.CamSpeed = 0.35;
// Check player death
        if (self.CamTargEnt.deadflag == DEAD_RESPAWNABLE)
        {
// player is dead
// make camera idle so that it finds another good target
            self.CamState = CAM_IDLE;
            self.Camnextthink = time + 3;
            self.Camforceidle = time + 1;
        }
        else
        {
            if (CamVisibleEnt(self.CamTargEnt))
            {
                self.CamPos = GetFollowCam();
                self.CamTarget = GetFollowTrg();
                if (pointcontents(self.CamPos) == CONTENT_SOLID)
                    InitFlybyMode(self.CamTargEnt);
            }
            else
            {
                InitFlybyMode(self.CamTargEnt);
            }
        }
    }
//  else if (self.CamState == ...

// Check destination visibility
    traceline(self.origin,self.CamPos,TRUE,self);
    if (trace_fraction != 1)
        self.CamCut = TRUE;
// Rotate the camera towards the target
// and move it towards the ideal position
    if (self.CamCut) {
//dprint("self.origin=");
//dprint(vtos(self.origin));
//dprint(" set to=");
//dprint(vtos(self.CamPos));
//dprint("\n");
        setorigin(self,self.CamPos);
//dprint("  now=");
//dprint(vtos(self.origin));
//dprint("\n");
	} else {
        vmove = self.CamPos - self.origin;
        vmove = self.CamSpeed * vmove;
        vmove = self.origin + vmove;
//dprint("self.origin=");
//dprint(vtos(self.origin));
//dprint(" set to=");
//dprint(vtos(self.CamPos));
//dprint("\n");
        setorigin(self, vmove);
//dprint("  now=");
//dprint(vtos(self.origin));
//dprint("\n");
    }

    if (self.CamCut)
        self.CamTargAim = self.CamTarget;
    else
        if (self.CamState == CAM_IDLE)
            self.CamTargAim = 0.02 * (self.CamTarget - self.CamTargAim) +
				self.CamTargAim;
        else
            self.CamTargAim = 0.2 * (self.CamTarget - self.CamTargAim) + self.CamTargAim;

// Maybe now the following is too much complicated but I don't care

    vmove = vectoangles(self.CamTargAim - self.origin);
    vmove_x = 360 - vmove_x;
    if (vmove_x > 180)
        vmove_x = vmove_x - 360;
    if (vmove_x > 70)
        vmove_x = 70;
    else if (vmove_x < -70)
        vmove_x = -70;
    self.CamCut = FALSE;
    self.fixangle = TRUE;
    self.angles_y = vmove_y;
    self.angles_x = vmove_x;
    self.angles_z = 0;
    self.v_angle = self.angles;
};

void() CamPreThink =
{
// Impulse handling (standard is not active)
    CamImpulses();
};

void() CamPlayerDisconnect =
{
	local entity p;

	p = find(world, classname, "CameraClient");
	while (p != world) {
		if (p.CamTargEnt == self) {
			p.CamState = CAM_IDLE;
			p.Camnextthink = time + 2;
		}
		p = find(p, classname, "CameraClient");
	}
};

void() InitCamClient =
{
    local entity spot;

    self.classname = "CameraClient";
//    setmodel (self, string_null);
	if (cvar("teamplay") & TEAM_CAPTURE_CUSTOM)
		setmodel (self, "progs/bit.mdl");
	else
		setmodel (self, "progs/v_spike.mdl");
    self.weaponmodel = string_null;
    setsize (self, '0 0 0', '0 0 0');
    self.velocity = '0 0 0';
    self.view_ofs = '0 0 0';
	self.movetype = MOVETYPE_FLY;
	self.solid = SOLID_NOT;
    self.takedamage = DAMAGE_NO;
    self.fixangle = TRUE;
    self.nextthink = -1;
    self.colormap = 0;
    self.CamPos = self.origin;
    makevectors(self.angles);
    self.CamTarget = self.CamPos + 100 * v_forward;
    self.CamTargAim = self.CamTarget;
    self.CamTargEnt = self;
    self.CamState = CAM_IDLE;
    self.CamCut = FALSE;
    self.CamMsgs = TRUE;
    self.Camnextthink = time;
    self.Camforceidle = time;
};

