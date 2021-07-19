classdef Dispersion
    properties
        data {mustBeNumeric}
        ene {mustBeNumeric, mustBeReal}
        info
    end
    methods
        % get dimension info
        function dim = edim(obj)
            dim=size(obj.data,1);
        end
        function s = sta(obj)
            % statistical factor at room temperture
            s=((1+1./(exp(obj.ene*0.0396)-1))./obj.ene)+(-(1./(exp(-obj.ene*0.0396)-1))./obj.ene);s(obj.ene<=0)=inf;
        end
        function dim = qdim(obj)
            dim=size(obj.data,2);
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
        % get pixel size
        function scale=escale(obj)
            scale=obj.info.escale;
        end
        % project
        function spec=sumq(obj,ind)
            if nargin<2
                ind=1:obj.qdim;
            end
            spec=sum(obj.data(:,ind),2);
        end
        function spec=sume(obj,ind)
            if nargin<2
                ind=1:obj.edim;
            end
            spec=sum(obj.data(ind,:),1);
        end
        % visualize
        function []=imagesc(obj,clim,correctsta)
            if nargin<3
                correctsta=1;
            end
            if nargin<2
                clim=[];
            end
            if correctsta
                im=obj.data./obj.sta';
            else
                im=obj.data;
            end
            if isempty(clim)
                if correctsta
                    clim=[max(prctile(im(:),5),0),prctile(im(:),95)];
                else
                    clim=[max(prctile(im(:),5),0),prctile(im(:),85)];
                end
            end
            imagesc([],obj.ene,im,clim);
            axis xy
            colormap hot
            beautifyfig
            ylabel('Energy (meV)')
            try
                xticks(obj.info.xtick)
                xticklabels(obj.info.xticklabel)
            catch
            end
        end

        function []=surf(obj,clim,correctsta)
            if nargin<3
                correctsta=1;
            end
            if nargin<2
                clim=[];
            end
            if correctsta
                im=obj.data./obj.sta';
            else
                im=obj.data;
            end
%             im=BM3D_QRS(im);
            im=filloutliers(im,'clip','movmedian',10);
            if isempty(clim)
                if correctsta
                    clim=[max(prctile(im(:),5),0),prctile(im(:),95)];
                else
                    clim=[max(prctile(im(:),5),0),prctile(im(:),85)];
                end
            end
            surf(1:obj.qdim,obj.ene,im);
            zlim(clim)
%             colormap hot
            beautifyfig
            ylabel('Energy (meV)')
            xlabel('Momentum')
            shading interp
            set(gca,'clim',clim)
        end
    end
end