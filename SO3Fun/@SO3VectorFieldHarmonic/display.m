function display(SO3VF,varargin)
% standard output
displayClass(SO3VF,inputname(1),[],'moreInfo',symChar(SO3VF),varargin{:});

if ~SO3VF.SO3F.isReal, disp('  isReal: false'); end
disp(['  bandwidth: ' num2str(SO3VF.SO3F.bandwidth)]);
disp(['  tangent space: ' , char(SO3VF.tangentSpace)]);

disp(' ')

end
