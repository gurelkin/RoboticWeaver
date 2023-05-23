function [ Im_rectified_temp] = PerformHomography( Im, p, p2 );
%PerformHomography Perform Homography on given image using two point sets

A = zeros(8,8);
b=  zeros(8,1);
for i=1:4
    A(((i-1)*2)+1, :) = [p(i,1) p(i,2) 1 0 0 0 -p(i,1)*p2(i,1) -p(i,2)*p2(i,1)];
    A(((i-1)*2)+2, :) = [0 0 0 p(i,1) p(i,2) 1 -p(i,1)*p2(i,2) -p(i,2)*p2(i,2)];
    b(((i-1)*2)+1) = p2(i,1);
    b(((i-1)*2)+2) = p2(i,2);
end
h = A\b;
H = [h(1:3)'; h(4:6)'; [h(7:8)', 1]];

TFORM = maketform('projective', H');
Im_rectified = imtransform(Im,TFORM);
Im_rectified_temp(:,:,1) = Im_rectified(:,:,1)';
Im_rectified_temp(:,:,2) = Im_rectified(:,:,2)';
Im_rectified_temp(:,:,3) = Im_rectified(:,:,3)';

% p_temp = H*[p2 ones(4, 1)]';
% p_res = abs(p_temp(1:2,:)./[p_temp(3,:); p_temp(3,:)])
end
