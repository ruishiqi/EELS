classdef LineProfile
    properties
        data {mustBeNumeric}
        ene {mustBeNumeric, mustBeReal}
        info
    end
    methods
        % get dimension info
        function dim = dim(obj)
            dim=size(obj.data,1);
        end
        function dim = edim(obj)
            dim=size(obj.data,2);
        end
        % get pixel size
        function scale=scale(obj)
            scale=obj.info.scale;
        end
        function scale=escale(obj)
            scale=obj.info.escale;
        end
        
        % get status info
        function bol=issaturated(obj)
            try
            bol=obj.info.issaturated;
            catch
                bol=0;
            end
        end
        function sumspec=sumall(obj)
            sumspec=squeeze(sum(obj.data,1))';
        end
        function zlppos=zlp(obj)
            [~,zlppos]=min(abs(obj.ene));
        end
        
        % plot
        function []=imagesc(obj)
            fig
            imagesc((1:obj.dim)*obj.scale,obj.ene,obj.data',[-1 1]*max(obj.data(:)))
            beautifyfig
            colorbar
            ylabel('Energy loss (meV)')
            xlabel('Beam position (nm)')
            axis xy
            clm=hot(255);
            clm2=clm(end:-1:1,[3 2 1]);
            clm3=[clm2;clm];
            clm3=clm3(21:end-20,:);
            colormap(clm3)
            colormap(clm3);
            try
                energywindows=obj.info.energywindows;
                ylim([mean(energywindows(1:2)),mean(energywindows(3:4))])
            catch
            end
        end
        
        function []=plot(obj)
            Shift_Plot(obj)
        end
        
        end
    end