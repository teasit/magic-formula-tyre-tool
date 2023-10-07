function [names, handles] = getParsers()
metaPackageObj = meta.package.fromName('tydex.parsers');
metaClassObj = metaPackageObj.ClassList;
isAbstract = [metaClassObj.Abstract];
isHidden = [metaClassObj.Hidden];
metaClassObj(isAbstract|isHidden) = [];
namesFull = {metaClassObj.Name};
namesSplit = cellfun(@(x)strsplit(x,'.'), namesFull, 'UniformOutput', 0);
names = cellfun(@(x)x{end},  namesSplit, 'UniformOutput', 0);
handles = cellfun(@str2func, namesFull, 'UniformOutput', 0);
end