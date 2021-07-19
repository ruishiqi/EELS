function EELS4Ddata=Initialize4DEELS(data,ene,pixelsize)
EELS4Ddata=EELS4D;
EELS4Ddata.data=data;
if numel(pixelsize)==1
    pixelsize=pixelsize*[1 1];
end
EELS4Ddata.info.xscale=pixelsize(1);
EELS4Ddata.info.yscale=pixelsize(2);
if numel(ene)==1
    EELS4Ddata.info.escale=ene;
    ene=(1:size(data,3))*ene;
    sumall=squeeze(sum(data,[1 2 4]));
    ene=ene-ene(sumall==max(sumall));
    EELS4Ddata.ene=ene;
else
    EELS4Ddata.info.escale=ene(2)-ene(1);
    EELS4Ddata.ene=ene;
end