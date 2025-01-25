state("SugarySpire_ExhibitionNight")
{
}

init
{
    vars.list = new MemoryWatcherList();
    var target = new SigScanTarget(0, "1D 8A C0 5B B4 19 53 3E 5D 82 E8 B3 AB 3A 36 A8 80 31 F2 29 9B 14 9F AD A3 BB FE 65 62 7C AE D1");
    foreach (var page in game.MemoryPages(false))
    {
        var scanner = new SignatureScanner(game, page.BaseAddress, (int)(page.RegionSize));
        var result = scanner.Scan(target);
        if (result != IntPtr.Zero)
        {
            print(":3");
            vars.list.Add(new StringWatcher(result+0xA0, 64) { Name = "room" });
            vars.list.Add(new MemoryWatcher<bool>(result+0xE0) { Name = "endlevelfade" });
            vars.list.Add(new MemoryWatcher<double>(result+0x88) { Name = "saveTimeSecs" });
            vars.list.Add(new MemoryWatcher<double>(result+0x80) { Name = "saveTimeMins" });
            break;
        }
    }
    if (vars.list.Count == 0)
        throw new Exception("Magic number is nowhere to be seen. Start the game in -livesplit mode!");
}

update
{
    vars.list.UpdateAll(game);
}

start
{
    if (vars.list["room"].Current == "hub_demohallway")
    {
        return true;
    }
}

split
{
    if ((vars.list["endlevelfade"].Changed && vars.list["endlevelfade"].Current == true) || (vars.list["room"].Changed && vars.list["room"].Current == "rm_credits"))
    {
        return true;
    }
}

reset
{
    if (vars.list["room"].Current == "rm_mainmenu")
    {
        return true;
    }
}

gameTime
{
    if (vars.list["saveTimeSecs"].Changed)
    return new TimeSpan(Convert.ToInt32(vars.list["saveTimeMins"].Current) / 60, Convert.ToInt32(vars.list["saveTimeMins"].Current) % 60, Convert.ToInt32(vars.list["saveTimeSecs"].Current));
}