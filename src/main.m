

% extract daily AWS data covering bare ice area
[~, ~] = func_preprocessPROMICEGC("H:\AU\promiceaws\day", "H:\AU\promiceaws\output");
% extract daily AWS data with ice surface height data
[dfaws, awsloc] = func_preprocessAWS("H:\AU\promiceaws\day", "H:\AU\promiceaws\output");
