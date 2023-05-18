classdef AppSettings < settings.AbstractSettings
    %APPSETTINGS Loads app settings from and saves them to persistent storage.
    properties (SetObservable, AbortSet)
        Fitter settings.FitterSettings
        View settings.ViewSettings
        LastSession settings.LastSessionSettings
        Version char
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
                s = settings();
                if ~hasGroup(s, obj.SettingsGroupTopLevel)
                    init(obj);
                end
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
                    obj.load()
                else
                    addGroup(s, obj.SettingsGroupTopLevel);
                    obj.save()
                end
            catch ME
                E = exceptions.CouldNotInitAppSettings();
                E = addCause(E, ME);
                throw(E)
            end
        end
        function reset(obj)
            try
                settings.AppSettings.clear()
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
                try
                    init(obj)
                catch
                    reset(obj)
                end
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
    methods (Static)
        function v = version()
            v = char.empty;
            s = settings();
            appName = settings.AbstractSettings.SettingsGroupTopLevel;
            if hasGroup(s, appName)
                appSettings = s.(appName);
                if hasSetting(appSettings, 'Version')
                    v = appSettings.Version.ActiveValue;
                end
            end
        end
        function clear()
            s = settings();
            group = settings.AbstractSettings.SettingsGroupTopLevel;
            if hasGroup(s, group)
                removeGroup(s, group)
            end
        end
    end
end

