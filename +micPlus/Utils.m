classdef Utils
%UTILS is a static class that contains a set of method useful for
%   dealing with graphical user interface.

    
%% Constant Properties
    properties (Constant)
       
    end

    %% Static Methods
    methods (Static)
        
        function evalAll(ceFns)
            for k = 1:length(ceFns)
                ceFns{k}();
            end
        end
       

    end % Static
end

