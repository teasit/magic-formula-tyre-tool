function [available, versionLatest] = checkUpdateAvailable(versionCurrent)
%CHECKUPDATEAVAILABLE Checks if update is available for application.
available = false;

versionValidPattern = ...
    digitsPattern() + '.' + digitsPattern() + '.' + digitsPattern();

versionCurrent = erase(versionCurrent, 'v');
assert(matches(versionCurrent, versionValidPattern)); 

url = 'https://api.github.com/repos/teasit/magic-formula-tyre-tool/releases/latest';
versionLatest = webread(url).tag_name;
versionLatest = erase(versionLatest, 'v');
assert(matches(versionLatest, versionValidPattern));

versionCurrentSplit = split(versionCurrent, '.');
versionLatestSplit = split(versionLatest, '.');

for i = 1:numel(versionCurrentSplit)
    v0 = str2double(versionCurrentSplit{i});
    v1 = str2double(versionLatestSplit{i});
    available = v1 > v0;
    if available
        return
    end
end
end

