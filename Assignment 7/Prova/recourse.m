function [value, mult, R] = recourse(lambda, yields, x, s, alpha)

S = size(yields,1);
R = sdpvar(1);
w_W = sdpvar(1); w_C = sdpvar(1);
e_H = sdpvar(1); e_L = sdpvar(1);
y_W = sdpvar(1); y_C = sdpvar(1);
z = sdpvar(1);
Costs = [150 230 260];
dummy = sdpvar(length(x), 1);

cons = [];
cons = [cons, (dummy == x ) : 'dual'];
cons = [cons, yields(s,1)* dummy(1) + y_W - w_W == 200];
cons = [cons, yields(s,2)* dummy(2) + y_C - w_C == 240];
cons = [cons, yields(s,3)* dummy(3) - e_H - e_L == 0];
cons = [cons, e_H <=6000];
cons = [cons, R == ((170 * w_W + 150 * w_C + 36 * e_H + 10 * e_L - 238 * y_W - 210*y_C) - Costs*dummy(1:3))];
cons = [cons, [w_W; w_C; e_H; e_L; y_W; y_C] >=0 ];
cons = [cons, z >= 0];
cons = [cons, z >= dummy(4) - R];



Obj = -lambda * R + (1-lambda)* z/alpha;

ops = sdpsettings('solver', 'gurobi', 'verbose', 0, 'cachesolvers', 1);

result = optimize(cons, Obj, ops); % solve the problem
R = double(R);
value = double(Obj); % get objective value
mult = -dual(cons('dual')); % get dual multiplier
end