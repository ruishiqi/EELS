function [BinnedData]=Bin2x2(RawData)
nx=2;ny=nx;
ydim=RawData.ydim/ny;
xdim=RawData.xdim/nx;
EEL=zeros(ydim,xdim,RawData.edim);
for ii=1:nx
    for jj=1:ny
        EEL=EEL+RawData.data(jj:ny:end,ii:nx:end,:);
    end
end
BinnedData=RawData;
BinnedData.data=EEL;
BinnedData.info.xscale=RawData.info.xscale*nx;
BinnedData.info.yscale=RawData.info.yscale*ny;
end