function [X, theta, optVal] = master_parallel(lambda, Costs, slopes, values, points)

% define decision variables
theta = sdpvar(size(values,1),1);
x = sdpvar(4,1);
S = size(values,1);

Cons = [];
Cons = [Cons, sum(x(1:3)) <= 500];
Cons = [Cons, x(1:3)>=0];
for s = 1:size(values,1)
   for i = 1:size(values,2)
    
       Cons = [Cons, theta(s) >= values(s,i) + (x - points(:,i))'  * squeeze(slopes(s,i,:))];
       
   end
end
 Cons = [Cons, x(4) >=-10000000];
  Cons = [Cons, x(4) <= 10000000];


if ~isempty(values)
  obj = (1-lambda) * x(4) - lambda * (Costs * x(1:3)) - 1/S*(sum(theta));
else
  Cons = [Cons, x(4)<=20000];
  obj = (1-lambda) * x(4) - lambda * (Costs * x(1:3));
end

Ops = sdpsettings ('solver','gurobi', 'verbose', 0);
Result = optimize(Cons, -obj, Ops);

X = double(x);
theta = double(theta);
optVal = double(obj);
end

