function imported=readNPYtoEELS(filename)
ind=find(filename=='.');
ind=ind(end);
fname=filename(1:ind-1);
data=double(readNPY([fname,'.npy']));
try
    json = jsondecode(fileread([fname,'.json']));
catch
    disp(['Unable to read json file'])
    return
end
if numel(size(data))==4
imported=EELS4D;
imported.data=permute(data,[1 2 4 3]);
ax=json.spatial_calibrations;
imported.info.xscale=ax(1).scale;
imported.info.yscale=ax(2).scale;
imported.info.escale=ax(4).scale*1e3;
imported.ene=(1:imported.edim)*ax(4).scale*1e3;
small=squeeze(sum(data,[1 2 3]));
imported.ene=imported.ene-imported.ene(small==max(small));
disp(['4D-EELS data successfully loaded from ',filename])
else
    ax=json.spatial_calibrations;
    imported=Initialize4DEELS(permute(data,[4 1 3 2]),ax(3).scale*1e3,1);
end