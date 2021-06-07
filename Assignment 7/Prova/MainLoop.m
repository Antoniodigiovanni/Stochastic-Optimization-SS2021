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
newSlope = [];
newValue = [];
tildeF= [];
t = [];
Revenue = [];
s=1;

tic;
i = 1;
[tildeX, ~, optVal] = master(lambda, Costs, slopes, values, points);
fprintf('First Master Solution\n')
fprintf('tildeX %f\n', tildeX)
fprintf('optVal: %f\n', optVal)
while notConverged
yalmip('clear');  
j = j+1;
fprintf('\n\nLoop n: %f,\n\n', j)
newSlope = zeros(S,1,4);
newValue = zeros(S,1);
for s = 1:S 
[value, mult, R] = recourse(lambda, yields, tildeX, s, alpha); 
newSlope(s,1,:) = mult * 1/S;
newValue(s,1) = value * 1/S;
end
slopes = [slopes, newSlope];
fprintf('Solved Recourse problem\n')
fprintf('newSlope: %f, \nnewValue: %f\n', newSlope, newValue);

time = [time, toc]; 
ub = [ub, optVal];
lb = [lb, (optVal + tildeQ) - newValue]; 
gap = [gap, newValue - tildeQ]; 
fprintf('ub: %f, lb: %f, gap: %f, T: %f\n', ub(end), lb(end), gap(end),toc);

if tildeQ == (1/S) * sum(newValue)
    %newValue == tildeQ
    %newValue - tildeQ < eps
    notConverged = false;
else
    points = [points, tildeX];
    values =  [values, newValue(:,1)];
    i = i +1;
    [tildeX, theta, optVal] = master(lambda, Costs, slopes, values, points);
    tildeQ = 1/S * sum(theta);
    
    fprintf('Solved Master Problem:\n\n')
    fprintf('tildeX %f\n', tildeX)
    fprintf('tildeQ: %f, optVal: %f\n\n', tildeQ, optVal)
   end 

end