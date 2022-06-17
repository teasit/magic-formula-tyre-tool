classdef AppSettings < settings.AbstractSettings
    %APPSETTINGS Loads app settings from and saves them to persistent storage.
    properties (SetObservable, AbortSet)
        Fitter settings.FitterSettings
        View settings.ViewSettings
        LastSession settings.LastSessionSettings
    end
    methods
        function load(obj)
            try
                settingsGroup = settings().(obj.SettingsGroupTopLevel);
                load@settings.AbstractSettings(obj, settingsGroup)
            catch ME
                E = exceptions.CouldNotLoadAppSettings();
                E = addCause(E, ME);
                throw(E)
            end
        end
        function save(obj)
            try
                settingsGroup = settings().(obj.SettingsGroupTopLevel);
                save@settings.AbstractSettings(obj, settingsGroup)
            catch ME
                E = exceptions.CouldNotSaveAppSettings();
                E = addCause(E, ME);
                throw(E)
            end
        end
        function init(obj)
            obj.Fitter = settings.FitterSettings();
            obj.View = settings.ViewSettings();
            obj.LastSession = settings.LastSessionSettings();
            try
                s = settings();
                if hasGroup(s, obj.SettingsGroupTopLevel)
                    load(obj)
                else
                    addGroup(s, obj.SettingsGroupTopLevel);
                    save(obj)
                end
            catch ME
                E = exceptions.CouldNotInitAppSettings();
                E = addCause(E, ME);
                throw(E)
            end
        end
        function reset(obj)
            try
                s = settings();
                if hasGroup(s, obj.SettingsGroupTopLevel)
                    removeGroup(s, obj.SettingsGroupTopLevel)
                end
                init(obj)
                save(obj)
            catch ME
                E = exceptions.CouldNotResetAppSettings();
                E = addCause(E, ME);
                throw(E)
            end
        end
        function obj = AppSettings()
            persistent pobj
            if isempty(pobj) || ~isvalid(pobj)
                init(obj)
                pobj = obj;
            else
                obj = pobj;
            end
        end
        function delete(obj)
            delete(obj.Fitter)
            delete(obj.View)
            delete(obj.LastSession)
        end
    end
end

