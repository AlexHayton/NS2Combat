//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// only way to get bots act on sayings
function SoundEffect:Start()
    
        // Asset must be assigned before playing.
        assert(self.assetIndex ~= 0)
        
        self.playing = true
        self.startTime = Shared.GetTime()
        
    end