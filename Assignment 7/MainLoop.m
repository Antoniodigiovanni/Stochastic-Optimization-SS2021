clear;
load data_farmer_cvar.mat;
yields = yields(1:50,:);
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
j=0;
t = [];
Revenue = [];
tic;
[tildeX, ~, optVal] = master(lambda, Costs, slopes, values, points);
fprintf('First Master Solution\n')
fprintf('tildeX %f\n', tildeX)
fprintf('optVal: %f\n', optVal)
while notConverged
    t = [t, tildeX(4)];
yalmip('clear'); 
newSlope = 0; 
newValue = 0; 
j = j+1;
fprintf('\n\nLoop n: %f,\n\n', j)
Revenues = 0;
for s = 1:S
[value, mult, R] = recourse(lambda, yields, tildeX, s, alpha); 
newSlope = newSlope + mult * 1/S;
newValue = newValue + value * 1/S;
Revenues = [Revenues, R];
end
fprintf('Solved Recourse problem\n')
fprintf('newSlope: %f, \nnewValue: %f\n', newSlope, newValue);
Revenue = [Revenue, mean(Revenues)];
time = [time, toc]; 
ub = [ub, optVal];
lb = [lb, (optVal + tildeQ) - newValue]; 
gap = [gap, newValue - tildeQ]; 
fprintf('ub: %f, lb: %f, gap: %f, T: %f\n', ub(end), lb(end), gap(end),toc);

if newValue - tildeQ < eps/1000
    %newValue == tildeQ
    %newValue - tildeQ < eps
    notConverged = false;
  else
    slopes = [slopes, newSlope];
    values = [values, newValue];
    points = [points, tildeX];
    [tildeX, tildeQ, optVal] = master(lambda, Costs, slopes, values, points);
    fprintf('Solved Master Problem:\n\n')
    fprintf('tildeX %f\n', tildeX)
    fprintf('tildeQ: %f, optVal: %f\n\n', tildeQ, optVal)
   end 

end