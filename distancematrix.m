function DM = distancematrix(dsites, ctrs)
%DISTANCEMATRIX  forms the distance matrix of two sets of points in R^d
%   DM = DISTANCEMATRIX(DSITES, CTRS) returns the matrix defined by
%       DM(i,j) = || DSITES_i - CTRS_j ||_2,
%   where DSITES is an M x d matrix representing a set of M data sites in R^d
%   and CTRS is an N x d matrix representing a set of N evaluation points.
%
%   DM = DISTANCEMATRIX(PTS) is a shorthand for DISTANCEMATRIX(PTS, PTS), i.e.
%       DM(i,j) = || PTS_i - PTS_j ||_2,
%   an important special case. Note DM here is symmetric.

% Algorithm is based on expanding the terms and computing each explicitly.
% Note that
%     || s_i - c_j ||_2 = [(s_i1 - c_j1)^2 + ... + (s_id - c_jd)^2]^(1/2),
% expanding (x-y)^2 = x^2 + y^2 - 2xy,
%         = [(s_ij^2 + ... + s_id^2) + (c_j1^2 + ... + c_jd^2)
%           - 2(s_i1 c_j1 + ... + s_id c_jd)]^(1/2).

% Symmetric version
if nargin < 2
    DM = sum(dsites'.^2,1)' + sum(dsites'.^2,1) - 2*(dsites*dsites');
    DM = max(DM, 0);
    DM = sqrt(DM);

% Asymmetric version
else
    ctrs = ctrs';
    DM = sum(dsites'.^2,1)' + sum(ctrs.^2,1) - 2*dsites*ctrs;
    DM = sqrt(DM);
end

end