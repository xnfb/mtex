function MTEXFigureMenu(varargin)

m = uimenu('label','MTEX');

uimenu(m,'label','Export','callback',@Export);
cm = uimenu(m,'label','Colormap');

% Colormap submenu
maps = getColormaps;

for i = 1:length(maps)
  uimenu(cm,'label',maps{i},'callback',@setColorMap);
end

%% colorcoding
cc = uimenu(m,'label','Colorcoding');
uimenu(cc,'label','Equal','callback',@setColorCoding);
uimenu(cc,'label','Tight','callback',@setColorCoding,'checked','on');


%% axis alignment
xdirection = uimenu(m,'label','X axis direction');
uimenu(xdirection,'label','East','callback',@setXAxisDirection);
uimenu(xdirection,'label','North','callback',@setXAxisDirection,'checked','on');
uimenu(xdirection,'label','West','callback',@setXAxisDirection);
uimenu(xdirection,'label','South','callback',@setXAxisDirection);

zdirection = uimenu(m,'label','Z axis direction');
uimenu(zdirection,'label','Out of plane','callback',@setZAxisDirection,'checked','on');
uimenu(zdirection,'label','Into plane','callback',@setZAxisDirection);

%% annotations
uimenu(m,'label','Show grid','checked','on');
uimenu(m,'label','Show ticks','checked','off');

%% fontsize

fs = uimenu(m,'label','Fontsize');
uimenu(fs,'label','10 points','callback',{@setFontSize,10},'checked','on');
uimenu(fs,'label','11 points','callback',{@setFontSize,11});
uimenu(fs,'label','12 points','callback',{@setFontSize,12});
uimenu(fs,'label','13 points','callback',{@setFontSize,13});
uimenu(fs,'label','14 points','callback',{@setFontSize,14});
uimenu(fs,'label','15 points','callback',{@setFontSize,15});
uimenu(fs,'label','16 points','callback',{@setFontSize,16});
uimenu(fs,'label','17 points','callback',{@setFontSize,17});
uimenu(fs,'label','18 points','callback',{@setFontSize,18});
uimenu(fs,'label','19 points','callback',{@setFontSize,19});
uimenu(fs,'label','20 points','callback',{@setFontSize,20});

end

function [cm,cmd] = getColormaps

fnd = dir([mtex_path filesep 'tools' filesep 'plot_tools' filesep '*ColorMap.m']);

% remove extension to create command
cmd = cellfun(@(x) x(1:end-2),{fnd.name},'UniformOutput',false);

% remove ColorMap
cm = cellfun(@(x) x(1:end-8),cmd,'UniformOutput',false);

end

%% Callbacks

function Export(obj,event) %#ok<INUSD>

savefigure;

end

% FontSize
function setFontSize(obj,event,fs) %#ok<INUSL>

uncheck = findobj(gcf,'parent',get(obj,'parent'));
set(uncheck,'checked','off');

o = findobj(gcf,'type','text');
set(o,'FontSize',fs);
set(obj,'checked','on');

end

% X Axis Direction
function setXAxisDirection(obj,event) %#ok<INUSD>


uncheck = findobj(gcf,'parent',get(obj,'parent'));
set(uncheck,'checked','off');
set(obj,'checked','on');
xAxis = get(obj,'label');

% for all axes
ax = findobj(gcf,'type','axes');
for a = 1:numel(ax)

  if ~isappdata(ax(a),'projection'), continue;end  
  setCamera(ax(a),'xAxisDirection',xAxis);
    
end

fn = get(gcf,'ResizeFcn');
fn(gcf,event);

end

% Z Axis Direction
function setZAxisDirection(obj,event)

uncheck = findobj(gcf,'parent',get(obj,'parent'));
set(uncheck,'checked','off');
set(obj,'checked','on');
zAxis = get(obj,'label');
zAxis(zAxis==' ')=[];

% for all axes
ax = findobj(gcf,'type','axes');
for a = 1:numel(ax)

  if ~isappdata(ax(a),'projection'), continue;end  
  setCamera(ax(a),'zAxisDirection',zAxis);
  
end

fn = get(gcf,'ResizeFcn');
fn(gcf,event);

end


% Color coding
function setColorCoding(obj,event) %#ok<INUSD>

uncheck = findobj(gcf,'parent',get(obj,'parent'));
set(uncheck,'checked','off');

if strcmpi(get(obj,'label'),'tight')
  setcolorrange('tight');
else
  setcolorrange('equal');
end


set(obj,'checked','on');

end

function setColorMap(obj,event) %#ok<INUSD>

uncheck = findobj(gcf,'parent',get(obj,'parent'));
set(uncheck,'checked','off');
map = get(obj,'label');
map = feval([map 'ColorMap']);
colormap(map);
set(obj,'checked','on');

end