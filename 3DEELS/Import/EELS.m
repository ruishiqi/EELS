classdef EELS
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
        % get pixel size
        function scale=xscale(obj)
            scale=obj.info.xscale;
        end
        function scale=yscale(obj)
            scale=obj.info.yscale;
        end
        function scale=escale(obj)
            try
                scale=obj.info.escale;
            catch
                scale=obj.ene(2)-obj.ene(1);
            end
        end

        % get status info
        function bol=isaligned(obj)
            bol=obj.info.isaligned;
        end
        function bol=isnormalized(obj)
            bol=obj.info.isnormalized;
        end
        function bol=issaturated(obj)
            bol=obj.info.issaturated;
        end
        function sumspec=sumall(obj)
            sumspec=squeeze(sum(obj.data,[1,2]))';
        end
        function zlppos=zlp(obj)
            [~,zlppos]=min(abs(obj.ene));
        end
        
        function []=plot(obj)
            plot(obj.ene,obj.sumall)
            beautifyfig
            xlabel('Energy loss (meV)')
            ylabel('Intensity (a.u.)')
        end
        function []=semilogy(obj)
            semilogy(obj.ene,obj.sumall)
            beautifyfig
            xlabel('Energy loss (meV)')
            ylabel('Intensity (a.u.)')
        end
    end
end