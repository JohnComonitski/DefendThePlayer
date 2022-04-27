#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai_shared;
#using scripts\zm\_zm;

#insert scripts\shared\shared.gsh;

#namespace clientids;

REGISTER_SYSTEM( "clientids", &__init__, undefined )
	
function __init__()
{
	callback::on_start_gametype( &init );
	callback::on_connect( &on_player_connect );
	callback::on_spawned( &on_player_spawned ); 
}	

function init()
{
	level.clientid = 0;
}

function on_player_connect()
{
	self.clientid = matchRecordNewPlayer( self );
	if ( !isdefined( self.clientid ) || self.clientid == -1 )
	{
		self.clientid = level.clientid;
		level.clientid++;
	}

}

function on_player_spawned() //this function will get called on every spawn! 
{
	level flag::wait_till( "initial_blackscreen_passed" );

	//Event listener

    count = 0;
    loop = true;
    while(loop){
        wait(1);
        if(self UseButtonPressed()){
            count++;
        }
        else{
            count = 0;
        }
        
        if(count == 5){
            IPrintLnBold("Starting Defend the Player");
            thread freezePlayers();
            loop = false;
        }
        if(level.round_number > 1){
            loop = false;
        }
    }
}

function freezePlayers(){
    players = GetPlayers();

    while(true){
        for (i = 0; i<players.size; i++){ 
            //Get Player       
            frozenPlayer = players[i];
            name = frozenPlayer.playername; 
            //Play Effect and Freeze Player
            playLightnightEffect(frozenPlayer.origin);
            frozenPlayer FreezeControlsAllowLook(true);
            //Check if player goes down
            thread checkForDown(frozenPlayer)
            //Notify Team
            IPrintLnBold(name+ " is frozen");
            IPrintLnBold("Defend " + name + " at ALL COST");
            wait(60);
            frozenPlayer FreezeControlsAllowLook(false);
        }
    }
}

function playLightnightEffect(pos){
    playsoundatposition(level.zmb_laugh_alias, pos);
    Playfx(level._effect["lightning_dog_spawn"], pos);
    playsoundatposition("zmb_hellhound_prespawn", pos);
    wait(1.5);
    playsoundatposition("zmb_hellhound_bolt", pos);
}

function checkForDown(frozenPlayer){
    for(j = 0; j < 60; j++){
        if(frozenPlayer InLastStand()){
            loop = false;
            IPrintLnBold("GAME OVER");
            wait(3);
            level notify("end_game");
        }
        wait(1);
    }	
}
