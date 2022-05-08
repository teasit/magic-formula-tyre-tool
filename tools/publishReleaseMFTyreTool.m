function publishReleaseMFTyreTool(version, title, changelogFile, packageFile, packagerFile)
%PUBLISHRELEASEMFTYRETOOL Automatic release to GitHub
arguments
    version char = getVersionFromAboutJSON
    title char = char.empty
    changelogFile char {mustBeFile} = 'CHANGELOG.md'
    packageFile char = 'MFTyreToolApp.mlappinstall'
    packagerFile char = 'MFTyreToolApp.prj'
end
pattern = 'v' + digitsPattern() + '.' + digitsPattern() + '.' + digitsPattern();
versionInvalid = ~matches(version, pattern);
if versionInvalid
    error('Invalid version pattern. Example: v1.0.1')
end

%Not needed, as version is synced with latest GitHub release
% updateVersionPackager(packagerFile, version)
matlab.apputil.package(packagerFile)

if isempty(title)
    title = version;
end

cmd = "gh release create %s --title %s --notes-file %s";
cmd = sprintf(cmd, version, title, changelogFile);
[status, cmdout] = system(cmd);
if status == 1
    warning('Failed to create release. Command-Line output:')
    disp(cmdout)
    return
end

cmd = 'gh release upload %s "%s"';
cmd = sprintf(cmd, version, packageFile);
[status, cmdout] = system(cmd);
if status == 1
    warning('Failed to upload packaged application. Command-Line output:')
    disp(cmdout)
    return
end
end

function updateVersionPackager(packagerFile, version)
version = erase(version, 'v');
text = readlines(packagerFile);
I = regexp(text, '<param.version>');
I = ~cellfun(@isempty, I);
text(I) = sprintf('    <param.version>%s</param.version>', version);
fileId = fopen(packagerFile, 'w');
try
    fprintf(fileId, '%s\n', text);
    fclose(fileId);
catch ME
    fclose(fileId);
    rethrow(ME)
end
end

function version = getVersionFromAboutJSON()
file = fullfile('src', 'about.json');
assert(isfile(file))
text = fileread(file);
config = jsondecode(text);
version = ['v' config.Version];
end