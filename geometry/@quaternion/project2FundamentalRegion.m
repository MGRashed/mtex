function [q,omega] = project2FundamentalRegion(q,CS,SS,q_ref)
% projects quaternions to a fundamental region
%
%% Input
%  q      - @quaternion
%  CS, SS - crystal / specimen @symmetry
%  q_ref  - reference @quaternion
%
%% Output
%  q     - @quaternion
%  omega - rotational angle to reference quaternion
%

%% get quaternions
if nargin <= 3, q_ref = idquaternion;end
q = quaternion(q);

%% no specimen symmetry
if nargin <=2 || numel(SS) <= 1 
    
  % maybe we can skip something
  omega = abs(dot(q,q_ref));
  ind = omega < cos(20*degree);

  if ~any(ind),
    omega = 2*acos(min(1,omega));
    return;
  end

  % symmetry elements
  qSym = quaternion(CS);
  
  % compute all distances to the fundamental regions
  omegaSym = abs(dot_outer(q_ref .* qSym,q));
  
  % find fundamental region
  [omega,idy] = max(omegaSym,[],1);
  
  % project to fundamental region
  qSym = inverse(qSym);
  q = q .* reshape(subsref(qSym,idy),size(q));
  
  % compute angle
  omega = reshape(2*acos(min(1,omega)),size(q));
  
%% with specimen symmetry
else 
  
  % symmetry elements
  qcs = quaternion(CS);
  qss = quaternion(SS);
  
  if q_ref.a==1
    d = dot_outer(qcs,qss);
    ind = any(isappr(d,1),1);
    ind(1) = false;
    qsym = subsref(qss,~ind) * qcs;
  else
    qsym = qss * reshape(q_ref .* qcs,1,[]);
  end
  
  % compute all distances to the fundamental regions  
  omegaSym = abs(dot_outer(qsym,q));
  
  % find fundamental region
  [omega,id] = max(omegaSym);
  
  % compute angle
  omega = reshape(2*acos(min(1,omega)),size(q));
  
  if all(id==1), return;end
  
  % project to fundamental region
  qcs = reshape(inverse(qcs),1,[]);
  qss = reshape(inverse(qss),1,[]);
  [idss,idcs] = ind2sub([numel(qss),numel(qcs)],id);
  q = reshape(subsref(qss,idss),size(q)) .* q .* reshape(subsref(qcs,idcs),size(q));
  
end
