function output = SFNMG(hkl)
%%SFNMG calculates the Structure Factor for face-centered Ni-Mn-Ga
% Created by: Bibek Karki on 02.08.2020
% Last updated: 
% hkl = row vectors of planes whose Bragg angles are calculated

if size(hkl,2) ~= 3
    error('The hkl planes need to be stored as row vectors.')
end

% the exponential part of the structure factor
sfexp = @(r,hkl) (exp(2*pi*1i * dot(r,hkl)));

% Atomic form factor at 0 degrees
% Taken as their atomic mass
fNi = 59; fMn = 55; fGa = 70;

% Face-centered lattice points
lp = [0 0 0;...
    0.5 0.5 0;...
    0 0.5 0.5;...
    0.5 0 0.5];

% motif points
rGa = [0 0 0];
rMn = [1/2 0 0];
rNi = [1/4 1/4 1/4;...
    3/4 1/4 1/4];


for i = 1 : size(hkl,1)
    
    hkl_i = hkl(i,:);
    
    % structure factor associated with centering
    flp = sfexp(lp(1,:),hkl_i)+sfexp(lp(2,:),hkl_i)+sfexp(lp(3,:),hkl_i)+sfexp(lp(4,:),hkl_i);

    % structure factor associated with the motif
    fmp = fGa*sfexp(rGa,hkl_i)+ fMn*sfexp(rMn,hkl_i) + fNi * (sfexp(rNi(1,:),hkl_i)+sfexp(rNi(2,:),hkl_i));

    % Final structure factor
    SF(i) = flp * fmp;

end

output = SF;
end
