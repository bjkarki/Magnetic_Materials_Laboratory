function output = bragg2theta(hkl,G,lamda)
%%bragg2theta calculates the bragg angle for diffraction
% Created by: Bibek Karki on 02.08.2020
% Last updated:
% hkl = row vectors of hkl planes whose Bragg angles are to be calculated
% G = metric tensor of the crystal system
% lamda = wavelngth of the wave source

if nargin == 1
    G = eye(3);
    lamda = 0.154181;
elseif nargin == 2
    lamda = 0.154181;
end


if size(hkl,2) ~= 3
    error('The hkl planes need to be stored as row vectors.')
end


for i = 1 : size(hkl,1)
    hkl_i = hkl(i,:);
    %%calculate the dspacings
    % g_hkl^2
    gsquared = hkl_i * (G\hkl_i');
    % d = 1 /g_hkl
    d = 1/sqrt(gsquared);
    % two-theta: 2d*sin(theta)=lamda
    twotheta(i) = 2*asind(lamda/(2*d));
end
    
output = twotheta;

end

