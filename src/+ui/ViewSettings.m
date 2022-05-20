classdef ViewSettings < handle
    properties
        TyreParametersTableViewSettings ui.TyreParametersTableViewSettings
        ViewLayoutSettings ui.ViewLayoutSettings
    end
    methods
        function obj = ViewSettings()
            obj.TyreParametersTableViewSettings = ...
                ui.TyreParametersTableViewSettings();
            obj.ViewLayoutSettings = ui.ViewLayoutSettings();
        end
    end
end