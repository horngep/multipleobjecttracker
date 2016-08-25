% Subtract and threshold a pair of images

function z = imsub(I1,I2,thresh)

    z = abs(double(I1) - double(I2));
    [n,m] = size(z);
    total = 0.0;
    for i=1:n
        for j=1:m
            if (z(i,j)>thresh) 
                z(i,j) = 1.0;
		total = total+1.0;
	    else 
                z(i,j) = 0.0;
            end
        end
    end
    z = z/total;
