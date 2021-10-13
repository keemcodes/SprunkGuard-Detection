// This is not to be ran as a Gamemode or Filterscript!
// This is simply an example of some coding done by Yisui Chaos
// If my comments are too long, it will be shown by me placing continuation periods(...) to the next line.

// Let's get started...
// For my Sprunk Guard Detection System...

// Ok, this will is a long piece of code, I tried my best to use the same format as hhcheck to make it easier to read.
// I will go through each part and explain what it does.

// This variable should be placed somewhere at the top of the script. It will be used and called later.
new SGcheckUsed = 0;

// the variable in which the player's position will be stored for safe player return after the check.
new Float:SGcheckPos[MAX_PLAYERS][4];

// the variable in which the player's interior will be stored.
new SGcheckInt[MAX_PLAYERS];

// the variable in which the player's virtual world wil be stored.
new SGcheckVW[MAX_PLAYERS];

// this variable will store the ID of the car we spawned.
new SGcar[MAX_PLAYERS] = INVALID_VEHICLE_ID;

// Let's assume that NGG uses either ZCMD or Y_Less' YCMD. This piece of code will work for either of the two.
CMD:sgcheck(playerid, params[]) // ZCMD/YCMD Command format.
{
	new string[128]; // For example purposes I just used a basic format for the string. 128 cells.
	// for better script optimization, I would suggest the actual characters+the name lenth for the cell number.
	new giveplayerid; // This is a variable in which the player's ID will be stored.

	// Also assuming NGG uses sscanf. This is the most efficient way of determining strings and splitting them.
	// I will not explain how sscanf works, it is a fairly complexed splitting method.
	if(sscanf(params, "u", giveplayerid)) // This basically just checks if the params offers a playerid.
	// it will also store the playerid into the variable "giveplayerid" which we previously defined.
	{
	    //if the params does not have a player ID specified it will return this message to the client.
		return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /sgcheck [player]");
	}
	if(IsPlayerConnected(giveplayerid)) // This checks if the playerid specified in the params is currently connected.
	{
		if(PlayerInfo[playerid][pAdmin] >= 3) // This checks if the player is an admin equal to or higher than level 3.
		//(which I believe is a general admin on ngg)
		{
      		if(GetPVarInt(giveplayerid, "sgcheck") == 1) // this checks if the player variable "sgcheck" is 1.
      		// This will be explained more later in the script
      		{
      		    //if the player is currectly being sprunk guard checked, it will return this message and halt the script.
      		    SendClientMessageEx(playerid, COLOR_WHITE, "That player is currently being checked for sprunk guard!");
				return 1; // this halts the script.
			}
			// there could be more checks like seeing if the player is tabbed similar to hhcheck, but for example purposes...
			// I'll leave such out.
            SetPVarInt(giveplayerid, "sgcheck", 1); // The player variable sgcheck will be set to 1.
            // This can be deleted after the task of sgchecking is complete.
            // The variable will be checked in the case another admin tries to sgcheck the same player, it won't allow them to...
            // unless the player isn't being sgchecked.
            
            
            // This will adds 1 to this variable everytime the code is called on a player.
   			SGcheckUsed++;


        	format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s has initiated SprunkGuard Check on %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
        	AdminBroadCast(COLOR_YELLOW, string, 2); // This is a custom admin broadcasting function...
        	// It is a function defined in the script iself...
        	// I'm sure NGG has something similar. In that case, change the name and params of the function to fit your needs.
  			format(string, sizeof(string), "V-World and Interior Used: %i", SGcheckUsed); // this is the format which will be...
  			// inserted into a string. SGcheckUsed is shown for %i integer. It just shows the current number of SGchecks performed by all admins.
		    SendClientMessage(playerid, COLOR_YELLOW, string); // the next formatted above is displayed to the admin client on this line.
		    
		    // GetPlayerName will return the name of the player ID specified. In this case, it'll be the playerid specified in the params..
		    // of /sgcheck.
		    // NGG has a way of removing the underscores from player names in a defined stock function. But for the sake of example...
		    // I'll use SA:MP's default function.
  			format(string, sizeof(string), "Checking %s for SprunkGuard, please wait....", GetPlayerName(giveplayerid));
		    SendClientMessage(playerid, COLOR_YELLOW, string);

			// this gets the player's position and places the coordinates into the variables we defined at the top of the script.
			GetPlayerPos(giveplayerid, SGcheckPos[giveplayerid][0], SGcheckPos[giveplayerid][1], SGcheckPos[giveplayerid][2]);
			
			// gets the player's facing angle and stores it into variable.
			GetPlayerFacingAngle(giveplayerid, SGcheckPos[giveplayerid][3]);
			
			// sets the virtual world variable to whatever the player's currect virtual world is.
			SGcheckVW[giveplayerid] = GetPlayerVirtualWorld(giveplayerid);
			// sets the interior variable to whatever the player's currect interior is.
			SGcheckInt[giveplayerid] = GetPlayerInterior(giveplayerid);
			
			// This would make sure the player isn't frozen. I don't think the vehicle will take damage if the player in the driver...
			// seat is frozen. That would render this check useless so it is important to be sure the player isn't frozen.
			TogglePlayerControllable(giveplayerid, 1);

			// This creates a dodo plane in the coordinates specified within the function.
			// It also saves the vehicle's ID to the function SGcar, because the function returns the ID of the vehicle.
			SGcar[giveplayerid] = CreateVehicle(593,1756.2932,-2668.3655,14.0089,274.7839, 233, 333, -1);
			// I would suggest adding in a method to make the vehicle impossible to be driven without freezing the player.
			// Setting the vehicle's gas to 0 is a way to do it.
			// Another way would be checking if the vehicle is a sprunkguard check spawned vehicle when the player attempts...
			// to start the engine. then obviously halting the start engine script from there.
			// EVEN ANOTHER way, probably the best would be some kind of use of playervelocity perhaps? I've personally...
			// never used the function, but I'm sure it might have something to keep a vehicle from moving.
			
			// This saves the vehicle's ID into the player variable "sgcheckveh".
			SetPVarInt(giveplayerid, "sgcheckveh", SGcar[giveplayerid]);
			
			// this shows the admin client the spawned vehicle's ID incase the script somehow fails and the vehicle needs to be manually deleted.
  			format(string, sizeof(string), "VehicleID: %i", GetPVarInt(giveplayerid, "sgcheckveh"));
		    SendClientMessageEx(playerid, COLOR_YELLOW, string);

			// Unlike HHcheck, I made this script to be usable by many admins at once. There is no wait time in the case of another admin...
			// using the command.
			// I did this simply by utilizing SA:MP infinite number of vworlds and interiors.
			// This will make sure all players being checked at sent to different virtual worlds and interiors to avoid any false positives...
			// (two players being checked at the same time, vehicles spawning ontop of eachother etc)
			
			// Sets the vehicles vworld and int to the next avaliable vworld and int.
			SetVehicleVirtualWorld(GetPVarInt(giveplayerid, "sgcheckveh"), SGcheckUsed);
			LinkVehicleToInterior(GetPVarInt(giveplayerid, "sgcheckveh"), SGcheckUsed);
			
			// I noticed that sometimes the vehicle would blow up extremely fast. To counter this, I set the of the vehicle to 5000.
		    SetVehicleHealth(GetPVarInt(giveplayerid, "sgcheckveh"), 5000);
		    
			// Set the player's virtual world and interior before teleporting them into the vehicle.
		    SetPlayerVirtualWorld(giveplayerid, SGcheckUsed);
		    SetPlayerInterior(giveplayerid, SGcheckUsed);
		    
		    // teleports the player into the vehicle.
			PutPlayerInVehicle(giveplayerid, GetPVarInt(giveplayerid, "sgcheckveh"), 0);
			
			// same as hhcheck, sets the player's camera to some random pos so they can't see what's happening.
			// You could place a textdraw over the player's map position possibly, I'm not so good at textdraws so I don't bother.
            SetPlayerCameraPos(giveplayerid, 785.1896,1692.6887,5.2813);
			SetPlayerCameraLookAt(giveplayerid, 785.1896,1692.6887,0);
			SetTimerEx("SprunkGuardCheck", 1500, 0, "dd", playerid, giveplayerid); // same as hhcheck, after all the mains are handled...
			// the rest is forwarded to a defined public function. The function uses milliseconds so 1500 represents 1.5 seconds.
			// basically, after 1.5 seconds has passed over the player is in the plane, the command is basically handed over to a function...
			// to display results.
		}
		else SendClientMessage(playerid, COLOR_GREY, "You are not authorized to use that command.");
	}
	else SendClientMessage(playerid, COLOR_GRAD1, "Invalid player specified.");
	return 1;
}
// THIS IS THE END OF THIS COMMAND.


// Here is a function similar to that of hhcheck, same format used for demonstration purposes.
forward SprunkGuardCheck(playerid, giveplayerid);
public SprunkGuardCheck(playerid, giveplayerid)
{
	new string[128]; // refer to what I said about string in the /sgcheck. Same logic can be used here.
	
	// I would suggest to check if the player is tabbed or logged off once again. Methods of doing this may vary between script.
	// for the example, I left such things out.

	// as we know, health is basically just a float so we created a float based variable to store the vehicle's health in.
    new Float:health;
    
    // gets the current health of the vehicle after sgcheck passed over to this function
    GetVehicleHealth(GetPVarInt(giveplayerid, "sgcheckveh"), health);
    if(health != 5000) // if the vehicle's health IS NOT 5000 then the player is using sprunk guard.
	{
        SendClientMessage(playerid, COLOR_GREEN, "____________________ SPRUNK GUARD CHECK RESULT_______________");
        format(string, sizeof(string), "The SprunkGuard Check on %s was {00F70C}positive{FFFFFF}. The player has SprunkGuard!", GetPlayerName(giveplayerid));
        SendClientMessage(playerid, COLOR_WHITE, string);
        SendClientMessage(playerid, COLOR_WHITE, "Vehicle Health before check: 5000.0");
        format(string, sizeof(string), "Vehicle Health after check: %.1f", health);
        SendClientMessage(playerid, COLOR_WHITE, string);
        SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________________________");
		format(string, sizeof(string), "%s sgchecked %s and returned %.1f HP", GetPlayerName(playerid), GetPlayerName(giveplayerid), health);
		Log("logs/sgcheck.log", string);
    }
    else // if anything else then not equal to 5000(which would obviously be 5000) the check returns negative.
	{
        SendClientMessage(playerid, COLOR_GREEN, "____________________ SPRUNK GUARD CHECK RESULT_______________");
        format(string, sizeof(string), "The SprunkGuard Check on %s was {FF0606}negative{FFFFFF}. The player was not using SprunkGuard.", GetPlayerName(giveplayerid));
        SendClientMessage(playerid, COLOR_WHITE, string);
        SendClientMessage(playerid, COLOR_WHITE, "Vehicle Health before check: 5000.0");
        format(string, sizeof(string), "Vehicle Health after check: %.1f", health);
        SendClientMessage(playerid, COLOR_WHITE, string);
        SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________________________");
		format(string, sizeof(string), "%s sgchecked %s and returned negative", GetPlayerName(playerid), GetPlayerName(giveplayerid));
		Log("logs/sgcheck.log", string);
    }
	// All of this simply sets the player back to where they were before the sgcheck was started.
	SetPlayerPosEx(giveplayerid, SGcheckPos[giveplayerid][0], SGcheckPos[giveplayerid][1], SGcheckPos[giveplayerid][2]);
	SetPlayerFacingAngle(giveplayerid, SGcheckPos[giveplayerid][3]);
	SetCameraBehindPlayer(giveplayerid);
	SetPlayerVirtualWorld(giveplayerid, SGcheckVW[giveplayerid]);
	SetPlayerInterior(giveplayerid, SGcheckInt[giveplayerid]);
	// vars like SGcheckVW/SGcheckINT don't have to be changed, for they will be everytime the command is used.
	
	// destroys the car
	DestroyVehicle(GetPVarInt(giveplayerid, "sgcheckveh"));

	// it is important to delete the player var "sgcheck", for it is used to determine if sgcheck is active on a player.
	DeletePVar(giveplayerid, "sgcheck");
	DeletePVar(giveplayerid, "sgcheckveh");
	// Don't quote me on this but I believe player vars are just saved to the player ID. I don't think they delete when the player disconnects
	// in that case...
	// I would suggest using OnPlayerDisconnect to delete these playervars.
	
	SGcar[giveplayerid] = INVALID_VEHICLE_ID;
    return 1;
}


