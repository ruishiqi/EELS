function [imported]=DM3Import( dm3filename )
struct=DM3Import0( dm3filename );
imported=EELS;
imported.data=struct.data;
imported.ene=struct.ene;
try
    imported.info.xscale=struct.xscale;
catch
    imported.info.xscale=struct.yscale;
end
try
    imported.info.yscale=struct.yscale;
catch
    imported.info.yscale=struct.xscale;
end
imported.info.escale=struct.escale;
imported.info.isaligned=false;
imported.info.isnormalized=false;