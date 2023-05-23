function [ new_image ] = black_correction( img )
%black_correction fix the background of an image (assuming black) to absolute
%black color and fix the foreground color accordingly.
%   Input - RGB Image to be corrected.
%   Output - Corrected image.

% back1 and back2 are two different ways to isolate black background.
% After calculating both ways we pick the best one for this particular 
% image.

% clear all;
% img = imread('IMAG0902.jpg');
ShowResults = false;

back1 = im2bw(rgb2gray(img),graythresh(img));
back2 = ~(var(double(img),1,3)<320 & mean(double(img),3)<120);

if sum(sum(back1))<sum(sum(back2))
    background = back1;
else
    background = back2;
end

if ShowResults
    figure;
    subplot(1,3,1); title('back1'); imshow(back1);
    subplot(1,3,2); title('back2'); imshow(back2);
    subplot(1,3,3); title('picked'); imshow(background);
end

% averaging black background
count = 0;
total(1,1,:) = [0 0 0];
for i=1:size(img,1)
    for j=1:size(img,2)
        if ~background(i,j)
            count = count+1;
            total = total+double(img(i,j,:));
        end
    end
end
average = total./count;

% black balance factor
factor = 255./(255-average);

% applying factor on image
img_d = double(img);
new_image(:,:,1) = factor(1,1,1).*(img_d(:,:,1)-average(1,1,1));
new_image(:,:,2) = factor(1,1,2).*(img_d(:,:,2)-average(1,1,2));
new_image(:,:,3) = factor(1,1,3).*(img_d(:,:,3)-average(1,1,3));
new_image = uint8(new_image);

if ShowResults
    figure; 
    subplot(1,2,1); title('original'); imshow(img);
    subplot(1,2,2); title('new'); imshow(new_image);
end

end

