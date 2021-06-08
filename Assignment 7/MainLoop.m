clear;
load data_farmer_cvar.mat;
%yields = yields(1:50,:);
S = size(yields,1);

slopes=[];
values=[];
points=[];
time=[];
ub=[];
lb=[];
gap=[]; 
eps = 0.0001;
notConverged = 1;
tildeQ = -inf;
lambda = 0.2;
alpha = 0.05;
Costs = [150 230 260]; %W;C;B

tic;
[tildeX, ~, optVal] = master(lambda, Costs, slopes, values, points);
while notConverged
yalmip('clear'); 
newSlope = 0; 
newValue = 0; 

for s = 1:S
[value, mult] = recourse(lambda, yields, tildeX, s, alpha); 
newSlope = newSlope + mult * 1/S;
newValue = newValue + value * 1/S;
end

time = [time, toc]; 
ub = [ub, optVal];
lb = [lb, (optVal + tildeQ) - newValue]; 
gap = [gap, newValue - tildeQ]; 
fprintf('ub: %f, lb: %f, gap: %f, T: %f\n', ub(end), lb(end), gap(end),toc);

if newValue - tildeQ < eps 
    notConverged = false;
  else
    slopes = [slopes, newSlope];
    values = [values, newValue];
    points = [points, tildeX];
    [tildeX, tildeQ, optVal] = master(lambda, Costs, slopes, values, points);
   end 

end