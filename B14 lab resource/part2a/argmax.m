% Find argmax in an array

function [u,v] = argmax(x,y,z)

[tmp_val,tmp_ind] = max(z);
[maxval,j] = max(tmp_val);
i = tmp_ind(j);
u=x(j);
v=y(i);
