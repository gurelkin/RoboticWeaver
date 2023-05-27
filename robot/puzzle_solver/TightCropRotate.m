function [ Res_Pieces ] = TightCropRotate( Pieces, method, showResults )
%TightCropRotate Detect each piece's area more closely, apply rotation and
% tight cropping

if (nargin<3)
    showResults = 0;
end
if (nargin<2)
    method = 1;
end

method

Res_Pieces = cell(size(Pieces));

for m=1:size(Pieces,1)
p = Pieces{m}.Data;

% Find quadrilateral frame tightly around piece
if method == 1
    [l1, l2, l3, l4] = FindQuadFrame1(p, showResults);
elseif method == 2
    [l1, l2, l3, l4] = FindQuadFrame2(p, showResults);
elseif method == 3
    [l1, l2, l3, l4] = FindQuadFrame3(p, showResults); 
elseif method == 4
    [l1, l2, l3, l4] = FindQuadFrame_HiRes(p, showResults); 
end

% Find rotation angle by averaging the 4 lines' deviation from the x-y axis
line = l1; theta(1) = atan((line.y2 - line.y1)/(line.x2 - line.x1));      % Top
line = l2; theta(2) = atan((line.y2 - line.y1)/(line.x2 - line.x1));      % Bottom
line = l3; theta(3) = -atan((line.x2 - line.x1)/(line.y2 - line.y1));      % Left
line = l4; theta(4) = -atan((line.x2 - line.x1)/(line.y2 - line.y1));      % Right

temp = theta(1:3);
minVar = var(theta(1:3));
newVar = var([theta(1) theta(2) theta(4)]);
if (newVar < minVar)
    minVar = newVar; 
    temp = [theta(1) theta(2) theta(4)];
end
newVar = var([theta(1) theta(3) theta(4)]);
if (newVar < minVar)
    minVar = newVar;
    temp = [theta(1) theta(3) theta(4)];
end
newVar = var([theta(2) theta(3) theta(4)]);
if (newVar < minVar)
    minVar = newVar;
    temp = [theta(2) theta(3) theta(4)];
end

clear theta;
theta = temp;

% Rot_theta = (sign(sum(theta))*max(abs(theta)))*180/pi
Rot_theta = mean(theta)*180/pi;

if showResults > 0
    figure;
    subplot(2,2,1); imshow(p); title('1. Initial piece');
end

temp = p(min(l1.y1, l1.y2):max(l2.y1, l2.y2), min(l3.x1, l3.x2):max(l4.x1, l4.x2), :);
if showResults > 0
    subplot(2,2,2); imshow(temp); title('2. Tight crop');
end

temp = imrotate(temp, Rot_theta, 'bicubic', 'crop');
if showResults > 0
    subplot(2,2,3); imshow(temp);
    title(['3. Rotation: ' num2str(Rot_theta) '\circ']);
end


% Choosing number of pixels to crop due to rotation.
% Mostly trial and error. Maybe should do a proper calculation somehow!

% p2c = 1+ floor(min(size(temp,1), size(temp,2))*abs(sind(Rot_theta)));
p2c = floor(abs(cosd(Rot_theta)^2)*0.5*mean([abs(l4.x1-l4.x2) abs(l1.y1-l1.y2) abs(l3.x1-l3.x2) abs(l2.y1-l2.y2)]));
temp2 = temp((1+p2c) : (end-p2c), (1+p2c) : (end-p2c), :);
if showResults > 0
    subplot(2,2,4); imshow(temp2); title('4. Final cropped piece');
end


Res_Pieces{m}.Data = temp2;
Res_Pieces{m}.Center = Pieces{m}.Center;

end



end

