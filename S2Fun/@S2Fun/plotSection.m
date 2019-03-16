function plotSection(sF,sec,varargin)
% 
%
% Syntax
%   N = vector3d.Z;
%   omega = pi/3;
%   plotSection(sF,N)
%   plotSection(sF,N,omega)
%
% Input
%  sF - @S2Fun
%  N  - normal direction
%  omega - 
%
% Output

[mtexFig,isNew] = newMtexFigure(varargin{:});

omega = linspace(0,2*pi,361);
  
if nargin > 2 && isnumeric(varargin{1})
  eta = varargin{1};
else
  eta = pi/2;
end

S2 = axis2quat(sec,omega)*axis2quat(orth(sec),eta)*sec;
    
d = reshape(sF.eval(S2),length(S2), []);
delta = getappdata(mtexFig.gca,'delta');
if isempty(delta)
  delta = max(d) / 200 ;
  setappdata(mtexFig.gca,'delta',delta);
end
delta = delta * get_option(varargin,'linewidth',1);

if isa(d,'double') && ~isreal(d), d = real(d);end
for j = 1:length(sF)
  if j > 1, mtexFig.nextAxis; end

  if strcmpi(get_option(varargin,'color'),'interp')
    varargin = delete_option(varargin,'color',1);
    
    dOuter = d(:, j)+delta;
    dInner = d(:, j)-delta;
    
    x = [dOuter .* S2.x, dInner .* S2.x];
    y = [dOuter .* S2.y, dInner .* S2.y];
    z = [dOuter .* S2.z, dInner .* S2.z];
    
    h = surface(x,y,z,[d,d],'parent',mtexFig.gca,'edgecolor','none','facecolor','interp');
    
  else
    x = d(:, j).*S2.x;
    y = d(:, j).*S2.y;
    z = d(:, j).*S2.z;
    
    h = plot3(x,y,z,'parent',mtexFig.gca);
  end
  view(mtexFig.gca,squeeze(double(sec)));
  set(mtexFig.gca,'dataAspectRatio',[1 1 1]);
  optiondraw(h,varargin{:});
end

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
