function EELS3Ddata=Initialize3DEELS(data,ene,pixelsize)
EELS3Ddata=EELS;
EELS3Ddata.data=data;
if numel(pixelsize)==1
    pixelsize=pixelsize*[1 1];
end
EELS3Ddata.info.xscale=pixelsize(1);
EELS3Ddata.info.yscale=pixelsize(2);
if numel(ene)==1
    EELS3Ddata.info.escale=ene;
    ene=(1:size(data,3))*ene;
    sumall=squeeze(sum(data,[1 2]));
    ene=ene-ene(sumall==max(sumall));
    EELS3Ddata.ene=ene;
else
    EELS3Ddata.info.escale=ene(2)-ene(1);
    EELS3Ddata.ene=ene;
end