function SO3F = rotate(SO3F,rot,varargin)
% rotate function on SO(3) by a rotation
%
% Syntax
%   SO3F = rotate(SO3F,rot)
%   SO3F = rotate(SO3F,rot,'right')
%
% Input
%  SO3F - @SO3FunCBF
%  rot  - @rotation
%
% Output
%  SO3F - @SO3FunCBF
%
% See also
% SO3FunHandle/rotate_outer

if check_option(varargin,'right')
  cs = SO3F.CS.rot;
  if length(cs)>2 && ~any(rot == cs(:))
    warning('Rotating an ODF with crystal symmetry will remove the crystal symmetry')
    SO3F.CS = crystalSymmetry;
  end
else
  ss = SO3F.SS.rot;
  if length(ss)>2 && ~any(rot == ss(:))
    warning('Rotating an ODF with specimen symmetry will remove the specimen symmetry')
    SO3F.SS = specimenSymmetry;
  end
end


if check_option(varargin,'right')
  SO3F.h = inv(rot) * SO3F.h;
else
  SO3F.r = rot * SO3F.r;
end
    
end
