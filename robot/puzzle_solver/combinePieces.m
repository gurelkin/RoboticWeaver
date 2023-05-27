function [ CombinedImage ] = combinePieces(Pieces, w, h, order)
% combinePieces Combine pieces to a single image
%   Pieces: cell array of separate image pieces, all must be squares of same size
%   w: number of columns
%   h: number of rows
%   order: a vector which is a permutation of the numbers {1,...,w*h}


if size(Pieces,1)~=w*h
    display('Error: number of pieces is different from entered width*height');
    display(['W=' num2str(w) ' h=' num2str(h) ' numPieces=' num2str(size(Pieces,1))]);
end

newMat = [];
for i=1:h
    row = [];
    for j=1:w
        row = [row, Pieces{order((i-1)*w+j)}.Data];
    end
    newMat = [newMat; row];
end

CombinedImage = newMat;
end

