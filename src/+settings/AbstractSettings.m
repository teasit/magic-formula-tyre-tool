classdef (Abstract) AbstractSettings < handle
    %ABSTRACTSETTINGS Abstract class for identifying settings classes.
    %Using this class, recursion is easier to implement, because if any
    %settings class has a child inheriting from AbstractSettings, the
    %recursion must continue.
    properties (Constant, Access = protected)
        %Name of top-level Settings Group: settings().<SettingsGroup>
        SettingsGroupTopLevel = 'mftyretool'
    end
    events (NotifyAccess = protected)
        %Triggered by any property change in the handle-hierarchy.
        SettingsChanged
    end
    methods
        function obj = AbstractSettings()
            metaprops = metaclass(obj).PropertyList;
            propnames = {metaprops.Name};
            isObservable = [metaprops.SetObservable];
            propnames = propnames(isObservable);
            for i = 1:numel(propnames)
                propname = propnames{i};
                addlistener(obj, propname, 'PostSet', ...
                    @(~,~) notify(obj, 'SettingsChanged'));
            end
        end
        function save(obj, settingsGroup)
            %SAVE Recursively save settings from persistent storage.
            props = properties(obj);
            for i = 1:numel(props)
                settingName = props{i};
                setting = obj.(settingName);
                if isa(setting, 'settings.AbstractSettings')
                    if ~hasGroup(settingsGroup, settingName)
                        settingsSubgroup = addGroup(settingsGroup, settingName);
                    else
                        settingsSubgroup = settingsGroup.(settingName);
                    end
                    save(setting, settingsSubgroup)
                else
                    if ~hasSetting(settingsGroup, settingName)
                        settingObj = addSetting(settingsGroup, settingName);
                    else
                        settingObj = settingsGroup.(settingName);
                    end
                    settingObj.PersonalValue = setting;
                end
            end
        end
        function load(obj, settingsGroup)
            %LOAD Recursively load settings from persistent storage.
            props = properties(obj);
            for i = 1:numel(props)
                try
                    settingName = props{i};
                    setting = obj.(settingName);
                    if isa(setting, 'settings.AbstractSettings')
                        settingsSubgroup = settingsGroup.(settingName);
                        load(setting, settingsSubgroup)
                    else
                        settingObj = settingsGroup.(settingName);
                        settingValue = settingObj.ActiveValue;
                        obj.(settingName) = settingValue;
                    end
                catch
                    continue
                end
            end
        end
    end
end

