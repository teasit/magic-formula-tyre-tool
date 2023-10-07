classdef LayoutSettings < settings.AbstractSettings
    %LAYOUTSETTINGS Contains app settings for layout (e.g. default padding)
    properties (Constant, AbortSet)
        DefaultPadding double = 5*ones(1,4);
        DefaultButtonHeight double = 22
        DefaultButtonWidthTextIcon = 110
        DefaultButtonWidthOnlyText = 75
        DefaultButtonWidthOnlyIcon = 25
        DefaultColumnSpacing double = 10
        DefaultRowSpacing double = 5
        DefaultSidebarWidth double = 250
    end
end