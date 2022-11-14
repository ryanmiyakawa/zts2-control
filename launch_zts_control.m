% delete timers:
if exist('purge', 'file')
    purge;
end

mpm addpath 

% micpath:
% First just get mic.Utils so we can have genpath_exclude:
% cMicPath = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'cnanders', 'matlab-instrument-control', 'src');
% addpath(cMicPath);
% addpath(mic.Utils.genpath_exclude(cMicPath, {'\+mic'}));


% Instantiate hardware with a clock:
dClockPeriod = 100/1000; % 100 ms
cClock = mic.Clock('global_clock', dClockPeriod);
hardware = hardware.Hardware('clock', cClock);


app = zts2control.ui.LSI_Control('hardware', hardware);



%%
app.build()

if strcmp(char(java.lang.System.getProperty('user.name')), 'rhmiyakawa')
    drawnow
%     app.hFigure.Position = [29        -165        1750        1000];
%    lsi.hFigure.Position = [-3966         500        1600         1000];
end