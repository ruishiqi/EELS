function []=setall(obj,propname,propval)
set(findobj(obj,'-property',propname),propname,propval)
end