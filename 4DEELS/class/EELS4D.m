classdef EELS4D
    properties
        data {mustBeNumeric}
        ene {mustBeNumeric, mustBeReal}
        info
    end
    methods
        % get dimension info
        function dim = xdim(obj)
            dim=size(obj.data,2);
        end
        function dim = ydim(obj)
            dim=size(obj.data,1);
        end
        function dim = edim(obj)
            dim=size(obj.data,3);
        end
        function dim = qdim(obj)
            dim=size(obj.data,4);
        end
        % get pixel size
        function scale=xscale(obj)
            scale=obj.info.xscale;
        end
        function scale=yscale(obj)
            scale=obj.info.yscale;
        end
        function scale=escale(obj)
            scale=obj.info.escale;
        end
        function s = sta(obj)
            % statistical factor at room temperture
            s=((1+1./(exp(obj.ene*0.0396)-1))./obj.ene)+(-(1./(exp(-obj.ene*0.0396)-1))./obj.ene);s(obj.ene<=0)=inf;
        end
        function dsp=proj2qe(obj,indy,indx)
            if nargin<3
                indx=[];
            end
            if nargin<2
                indy=[];
            end
            if isempty(indx)
                indx=1:obj.xdim;
            end
            if isempty(indy)
                indy=1:obj.ydim;
            end
        dsp=Dispersion;
        dsp.ene=obj.ene;
        dsp.data=squeeze(mean(obj.data(indy,indx,:,:),[1 2]));
        end
        
        function map=proj2xy(obj,inde,indq)
            if nargin<3
                indq=[];
            end
            if nargin<2
                inde=[];
            end
            if isempty(indq)
                indq=1:obj.qdim;
            end
            if isempty(inde)
                inde=1:obj.edim;
            end
        map=squeeze(sum(obj.data(:,:,inde,indq),[3 4]));
        end
        
        function sz=size(obj)
            sz=size(obj.data);
        end
        function zlppos=zlp(obj)
            [~,zlppos]=min(abs(obj.ene));
            if numel(zlppos)>1
                zlppos=mean(zlppos);
            end
        end
        function []=imageqe(obj,clim,correctsta)
            if nargin<3
                correctsta=1;
            end
            if nargin<2
                clim=[];
            end
            dsp=proj2qe(obj);
            imagesc(dsp,clim,correctsta)
        end
        function []=histogram(obj)
            histogram(obj.data(:));
        end
    end
end