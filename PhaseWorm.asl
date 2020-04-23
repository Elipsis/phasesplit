state ("PhaseWorm")
{
}
 
startup
{
    print("Starting Up!");
    refreshRate = 60;
}
 
init
{
    print ("Initializing!");
   
    vars.currentLevel = 0;
    vars.lastLevel = 30;
   
    //Looking for DEFACEF00D
    vars.scanTarget = new SigScanTarget(0, "0D F0 CE FA DE 00 00 00");
   
    IntPtr ptr = IntPtr.Zero;
   
    //Scan the game, I think.
    foreach (var page in game.MemoryPages())
    {
        var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
        ptr = scanner.Scan(vars.scanTarget, 8);    
        if (ptr != IntPtr.Zero) {
            print ("ptr is " + ptr);
            vars.sigaddress = ptr;
            break;
        }
    }
   
    if (ptr == IntPtr.Zero)
    {
    //  throw new Exception("Couldn't find a pointer I want! Game is still starting or an update broke things!");
        print ("Couldn't find a pointer I want! Game is still starting or an update broke things!");
    }
   
    print("Base Signature Address found: " + vars.sigaddress.ToString("X"));
   
    vars.watchers = new MemoryWatcherList();
    vars.watchers.Add(new MemoryWatcher<float>((IntPtr)vars.sigaddress + 0x8) {Name = "IGT"}); 
    vars.watchers.Add(new MemoryWatcher<int>((IntPtr)vars.sigaddress + 0xc) {Name = "levelNumber"});   
    vars.watchers.Add(new MemoryWatcher<bool>((IntPtr)vars.sigaddress + 0x10) {Name = "isTiming"});
    vars.watchers.Add(new MemoryWatcher<bool>((IntPtr)vars.sigaddress + 0x11) {Name = "hasWon"});
   
}
 
update
{
    vars.watchers.UpdateAll(game);
   
    /*
    print ("IGT: " + vars.watchers["IGT"].Current);
    print ("Level: " + vars.watchers["levelNumber"].Current);
    print ("isTiming: " + vars.watchers["isTiming"].Current);
    print ("hasWon: " + vars.watchers["hasWon"].Current);*/
}
 
isLoading
{
	/*
    if(vars.watchers["isTiming"].Current == false)
    {
        return true;
    }
   
    else
    {
        return false;
   }
   */
   
   //Always return true now due to gameTime logic.
   return true;
}

gameTime
{
    vars.igt = Convert.ToInt32(vars.watchers["IGT"].Current * 1000);
    return new TimeSpan(0, 0, 0, 0, vars.igt);
}
 
start
{
    if(vars.watchers["isTiming"].Current == true && (int)vars.watchers["levelNumber"].Current == 1)
    {
        vars.currentLevel = (int)vars.watchers["levelNumber"].Current;
        return true;
    }
   
    return false;
}
   
 
split
{
    if(vars.watchers["hasWon"].Current == true && vars.currentLevel == (int)vars.watchers["levelNumber"].Current)
    {
        vars.currentLevel++;
        return true;
    }
   
	else
	{
		return false;
	}
}

reset
{
	if(vars.watchers["levelNumber"].Current == 0 && vars.watchers["levelNumber"].Old > 0)
	{
		return true;
	}
	
	else
	{
		return false;
	}
	
}
 
exit
{
}