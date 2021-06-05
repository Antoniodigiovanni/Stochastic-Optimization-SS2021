function [X, theta, optVal] = master(lambda, Costs, slopes, values, points)

% define decision variables
theta = sdpvar;
x = sdpvar(4,1);



Cons = [];
Cons = [Cons, sum(x(1:3)) <= 500];
Cons = [Cons, x>=0];
for i = 1:length(values)
   Cons = [Cons, theta >= values(i) + (x - points(:,i))'  * slopes(:,i)];
end

if ~isempty(values)
  obj = (1-lambda) * x(4) - lambda * (Costs * x(1:3)) - theta;
else
  Cons = [Cons, x(4)<=20000000];
  obj = (1-lambda) * x(4) - lambda * (Costs * x(1:3));
end

Ops = sdpsettings ('solver','gurobi', 'verbose', 0);
Result = optimize(Cons, -obj, Ops);

X = double(x);
theta = double(theta);
optVal = double(obj);
end

