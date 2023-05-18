function publishRelease(version, title, changelogFile, packageFile, packagerFile, packagerToolboxFile)
%PUBLISHRELEASE Automatic release to GitHub
arguments
    version char = getVersionFromAboutJSON()
    title char = char.empty
    changelogFile char {mustBeFile} = 'CHANGELOG.md'
    packageFile char = 'MagicFormulaTyreTool.mltbx'
    packagerFile char = 'MagicFormulaTyreTool.prj'
    packagerToolboxFile char = 'ToolboxPackager.prj'
end
pattern = 'v' + digitsPattern() + '.' + digitsPattern() + '.' + digitsPattern();
versionInvalid = ~matches(version, pattern);
if versionInvalid
    error('Invalid version pattern. Example: v1.0.1')
end

results = runtests('OutputDetail', 0);
failed = [results.Failed];
if any(failed)
    error('Unit Tests failed. Aborted release publish')
end

updateVersionPackager(packagerFile, version)
matlab.apputil.package(packagerFile)
matlab.addons.toolbox.toolboxVersion(packagerToolboxFile, erase(version, 'v'));
matlab.addons.toolbox.packageToolbox(packagerToolboxFile);

if isempty(title)
    title = version;
end

system('git add *')
system(sprintf('git commit -m "publish release %s"', version))
system('git push')

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
    warning('Failed to upload packaged toolbox. Command-Line output:')
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