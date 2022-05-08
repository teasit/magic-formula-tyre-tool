classdef ViewSettings < handle
    properties
        TyreParametersTableViewSettings ui.TyreParametersTableViewSettings
    end
    methods
        function obj = ViewSettings()
            obj.TyreParametersTableViewSettings = ...
                ui.TyreParametersTableViewSettings();
        end
    end
end