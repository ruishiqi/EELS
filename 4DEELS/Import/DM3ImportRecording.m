function [imported]=DM3ImportRecording( dm3filename )
struct=DM3Import0( dm3filename );
imported=Initialize4DEELS(permute(struct.data,[4 3 2 1]),struct.yscale*1e3,1);
