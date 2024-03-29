function [X, theta, optVal] = master(lambda, Costs, slopes, values, points)

% define decision variables
theta = sdpvar(size(values,1),1);
x = sdpvar(4,1);
S = size(values,1);
prova = [0 ; 0 ; 0; 20000];

Cons = [];
Cons = [Cons, sum(x(1:3)) <= 500];
Cons = [Cons, x(1:3)>=0];
for s = 1:size(values,1)
   for i = 1:size(values,2)
    Cons = [Cons, theta(s) >= values(s,i) + (x - points(:,i))'  * squeeze(slopes(s,i,:))];
    %fprintf('\n\n %f', values(s,i) + (prova - points(:,i))'  * squeeze(slopes(s,i,:)))
   end
end

  Cons = [Cons, x(4) >=-10000000];
  Cons = [Cons, x(4) <= 10000000];

if ~isempty(values)
  obj = (1-lambda) * x(4) - lambda * (Costs * x(1:3)) - mean(theta);
else
  obj = (1-lambda) * x(4) - lambda * (Costs * x(1:3));
end

Ops = sdpsettings ('solver','gurobi', 'verbose', 0);
Result = optimize(Cons, -obj, Ops);
%fprintf('\n\nTheta in the master is equal to: %f\n\n', double(theta))
X = double(x);
theta = double(theta);
optVal = double(obj);
end

