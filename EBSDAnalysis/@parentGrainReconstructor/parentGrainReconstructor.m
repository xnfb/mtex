classdef parentGrainReconstructor < handle
% class guiding through the parent grain reconstruction process 
%
% Syntax
%   job = parentGrainReconstructor(ebsd, grains)
%
%   job = parentGrainReconstructor(ebsd, grains, p2c0)
%
% Input
%  ebsd - @EBSD
%  grains - @grain2d
%  p2c0 - initial guess for the parent to child orientation relationship
%
% Class Properties
%  grains    - grains at the current stage of reconstruction
%  ebsd      - EBSD at the current stage of reconstruction
%  csParent  - @crystalSymmetry of the parent phase
%  csChild   - @crystalSymmetry of the child phase
%  p2c       - refined parent to child orientation relationship
%  mergeId   - list of ids to the merged grains
%  fit       - 
%  graph     -
%  votes     -
%  numChilds         - number of child grains for each parent grain
%  isTransformed     - child grains that have been reverted from child to parent phase
%  isMerged          - child grains that have been merged into a parent grain    
%  transformedGrains - transformed measured grains 
%  parentGrains - measured and reconstructed parent grains
%  childGrains  - not yet reconstructed child grains
%  variantId    - reconstructed variant ids
%  packetId     - reconstructed packet ids
%
% See also
% MaParentGrainReconstruction TiBetaReconstruction
%

  properties
    grains         % grains at the current stage of reconstruction
    p2c            % parent to child orientation relationship
    useBoundaryOrientations = false
    
    mergeId        % a list of ids to the merged grains
    pParentId      % probabilities of parentIds
    
    votes          % votes computed by calcGBVotes or calcTPVotes
    fit            % misFit of the votes
    graph          % graph computed by calcGraph
  end
  
  properties (Dependent=true)
    csParent        % parent symmetry
    csChild         % child symmetry
    childPhaseId    % phase id of the child phase
    parentPhaseId   % phase id of the parent phase
    variantMap      % allows to reorder variants
  end
  
  properties (Dependent=true)
    ebsd            % EBSD at the current stage of reconstruction
    
    numChilds       % number of child grains for each parent grain
    isTransformed   % child grains that have been reverted from child to parent phase
    isMerged        % child grains that have been merged into a parent grain    
    
    transformedGrains  % transformed measured grains 
    parentGrains       % 
    childGrains        %
    
    variantId       %
    packetId        %
  end
  
  properties (Hidden=true)
    ebsdPrior      % EBSD prior to reconstruction
    grainsPrior    % grains prior to reconstruction
  end
  
  methods

    function job = parentGrainReconstructor(ebsd,varargin)

      % set up ebsd and grains
      job.ebsdPrior = ebsd;
      job.grains = getClass(varargin,'grain2d');
      job.grainsPrior = job.grains;
      
      if isempty(job.grains)
        [job.grains, job.ebsdPrior.grainId] = ...
          calcGrains(ebsd('indexed'),'threshold',3*degree,varargin);
      end

      % project EBSD orientations close the grain mean orientations
      job.ebsdPrior = job.ebsdPrior.project2FundamentalRegion(job.grains);
      
      job.mergeId = (1:length(job.grains)).';
      
      % check for provided orientation relationship
      job.p2c = getClass(varargin,'orientation',orientation);
      
      % determine parent and child phase
      if isempty(job.p2c)
                
        % try to guess parent and child phase
        numPhase = accumarray(ebsd.phaseId,1,[length(ebsd.CSList),1]);
        indexedPhasesId = find(~cellfun(@ischar,ebsd.CSList));
        numPhase = numPhase(indexedPhasesId );
        
        [~,maxPhase] = max(numPhase);
        job.csChild = ebsd.CSList{indexedPhasesId(maxPhase)};
        
        [~,minPhase] = min(numPhase);
        if minPhase ~= maxPhase
          job.csParent = ebsd.CSList{indexedPhasesId(minPhase)};
        end      
      end
      
    end
    
    function cs = get.csParent(job)
      cs = job.p2c.CS;
    end
    
    function set.csParent(job,cs)
      job.p2c.CS = cs;
    end
    
    function cs = get.csChild(job)
      cs = job.p2c.SS;
    end
    
    function set.csChild(job,cs)
      job.p2c.SS = cs;
    end
    
    function id = get.parentPhaseId(job)
      id = job.grains.cs2phaseId(job.csParent);
    end
    
    function id = get.childPhaseId(job)
      id = job.grains.cs2phaseId(job.csChild);
    end
    
    function out = get.numChilds(job)
      out = accumarray(job.mergeId,1);
    end
    
    function out = get.isMerged(job)
      % the merged ones are those 
      out = job.numChilds(job.mergeId)>1;
    end
    
    function out = get.isTransformed(job)
      % which initial grains have been already reconstructed
      
      out = job.grainsPrior.phaseId == job.childPhaseId & ...
        job.grains.phaseId(job.mergeId) == job.parentPhaseId;
    end
    
    function out = get.parentGrains(job)
      
      out = job.grains( job.grains.phaseId == job.parentPhaseId );
      
    end
    
    function out = get.childGrains(job)
      
      out = job.grains( job.grains.phaseId == job.childPhaseId );
      
    end
    
    function out = get.transformedGrains(job)
      out = job.grainsPrior(job.isTransformed);
    end
    
    function set.transformedGrains(job,grains)
      job.grainsPrior(job.isTransformed) = grains;
    end
    
    function out = get.packetId(job)
      
      if isfield(job.grainsPrior.prop,'packetId')
        out = job.grainsPrior.prop.packetId;
      else
        out = NaN(size(job.grainsPrior));
      end
    end
    
    function set.packetId(job,id)
      job.grainsPrior.prop.packetId = id;
    end
    
    function out = get.variantId(job)
      
      if isfield(job.grainsPrior.prop,'variantId')
        out = job.grainsPrior.prop.variantId;
      else
        out = NaN(size(job.grainsPrior));
      end
    end
    
    function set.variantId(job,id)
      job.grainsPrior.prop.variantId = id;
    end
     
    function set.variantMap(job,vMap)
      job.p2c.opt.variantMap = vMap;
    end
    
    function vMap = get.variantMap(job) 
      if ~isfield(job.p2c.opt,'variantMap') || isempty(job.p2c.opt.variantMap)
        vMap = 1:length(job.p2c.variants); 
      else
        vMap = job.p2c.opt.variantMap;
      end      
    end
    
    function ebsd = get.ebsd(job)
      ebsd = calcParentEBSD(job);
    end
        
  end

end