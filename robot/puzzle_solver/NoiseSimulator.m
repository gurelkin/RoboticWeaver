for t=1:6
clc;
clearvars -except t;
close all;

suppressOutput = true;
OutPath = 'NoiseTests\';
ImPath = 'ImageDB\';
ShowSubResults = true;


switch t
    case 1
        ImFilename = 'Cho_432_3';
    case 2
        ImFilename = 'Cho_432_6';
    case 3
        ImFilename = 'Cho_432_7';
    case 4
        ImFilename = 'Cho_432_11';
    case 5
        ImFilename = 'Cho_432_16';
    case 6
        ImFilename = 'Cho_432_18';
end
disp(ImFilename);

extension = '.png';
%I = double(imread([ImPath, ImFilename]));
[I, map] = imread([ImPath, ImFilename, extension]);
 I = 256*double(I)/65535; % for Cho images
% I = double(I); % for bgu images
imshow(uint8(I));

% Add noise
N = 2; % use 6 for Gussian or Salt & pepper and 2 for Poisson or Rotated
nLevel = 20; % Use 10 for Gussian and 20 for Salt & pepper
Im = cell(N,1);
ImPath = cell(N,1);
NoiseType = 4; % 1 = Gussian. 2 = salt & pepper. 3 = Poisson. 4 = Rotated. 5 = Light.
angle = 3; % angle of rotation.
partSize = 28; % A square part size, this size should divide with the image
                                   % size or the image is cropped.
ph = size(I,1)/partSize;
pw = size(I,2)/partSize;
figure;
for i=1:N
    switch NoiseType
        case 1
           Im{i} = I + nLevel*(i-1)*randn(size(I)); % Gaussian noise to each channel
           subplot(floor(N/2),floor(N/2), i);
           imshow(uint8(Im{i}))
           title(['Noise level: ', num2str(nLevel*(i-1))]); 
           ImPath{i} = [OutPath, ImFilename, '_nLevel=', num2str((i-1)*nLevel), '.jpg'];
        case 2
           Im{i} = imnoise(uint8(I),'salt & pepper',(i-1)/nLevel);
           subplot(floor(N/2),floor(N/2), i);
           imshow(uint8(Im{i}))
           title(['Noise level: ', num2str(100*(i-1)/nLevel)]); 
           ImPath{i} = [OutPath, ImFilename, '_nLevel=', num2str(100*(i-1)/nLevel), '.jpg'];
        case 3
           Im{1} = I;
           Im{2} = imnoise(uint8(I),'poisson');
           imshow(uint8(Im{i}))
           title('Poisson Noise'); 
           ImPath{1} = [OutPath, ImFilename, '_Original.jpg'];
           ImPath{2} = [OutPath, ImFilename, '_Poisson.jpg'];
        case 4
           Im{1} = I;
           for m=0:(ph-1)
                for k=1:pw
                     Pieces{m*pw+k}.Data = ...
                         uint8(imrotate(Im{1}(m*partSize+1:(m+1)*partSize,(k-1)*partSize+1:k*partSize,:),angle*(2*rand(1)-1)));
                     PieceSize = size(Pieces{m*pw+k}.Data);
                     temp = Pieces{m*pw+k}.Data(3:PieceSize(1)-2,3:PieceSize(2)-2,:);
                     clear Pieces{m*pw+k}.Data;
                     Pieces{m*pw+k}.Data = temp;
                     Pieces{m*pw+k}.Data = imresize(Pieces{m*pw+k}.Data,[28 28]);
                end
           end
           Im{2} = combinePieces(Pieces, pw,ph ,1:ph*pw);
           imshow(uint8(Im{i}))
           title('Rotation'); 
           ImPath{1} = [OutPath, ImFilename, '_Original.jpg'];
           ImPath{2} = [OutPath, ImFilename, '_Rotate.jpg']; 
        case 5
           Im{1} = I;
           colorTransform = makecform('srgb2lab');
           Imlab = applycform(uint8(Im{1}), colorTransform);
           for m=0:(ph-1)
                for k=1:pw
                     Pieces{m*pw+k}.Data = ...
                         Imlab(m*partSize+1:(m+1)*partSize,(k-1)*partSize+1:k*partSize,:);
                     Pieces{m*pw+k}.Data(:,:,1) = Pieces{m*pw+k}.Data(:,:,1) + 20*rand(1);
                end
           end
           temp = combinePieces(Pieces, pw,ph ,1:ph*pw);
           colorTransform = makecform('lab2srgb');
           Im{2} = applycform(temp, colorTransform);
           imshow(uint8(Im{i}))
           title('Lightness'); 
           ImPath{1} = [OutPath, ImFilename, '_Original.jpg'];
           ImPath{2} = [OutPath, ImFilename, '_Light.jpg']; 
    end
    % Save the resulting image, to be used as input for the algorithm 
    imwrite(uint8(Im{i}), ImPath{i});
end
ImPath

%
% Run the algorithm

for n=2:N
    
currentBestBuddies = 0;

firstPartToPlace = -1; % random seed
compatibilityFunc = 1; % Prediction-based Compatibility (Default)
shiftMode = 2; % Growing largest segment using estimationFunc  estimation metric to 
                                % measure convergence (Default)
colorScheme =1; % LAB (Default)
greedyType = 3; % Narrow Best Buddies with average (Default)
estimationFunc = 0; % Best Buddies (Default)
outputMode = 0; % Only return values
% outputMode = 1; % Output image only (Default)
runTests = false;
normalMode = 4; % Exponent according to first quartile value (Default)
resPath = OutPath;
debug = 0; % Off

if ShowSubResults
    clear Pieces;
    for m=0:(ph-1)
        for k=1:pw
            Pieces{m*pw+k}.Data = uint8(Im{n}(m*partSize+1:(m+1)*partSize,(k-1)*partSize+1:k*partSize,:));
        end
    end
end

% 5 iterations
% Save best solution so far according to "Best Buddies" estimation metric.
for i=1:3
    [directCompVal_, neighborCompVal_, estimatedBestBuddiesCorrectness_, estimatedAverageOfProbCorrectness_, solutionPartsOrder_, segmentsAccuracy_, numOfIterations_] = JigsawSolver(ImPath{n}, firstPartToPlace, partSize, compatibilityFunc, shiftMode, colorScheme, greedyType, estimationFunc, outputMode, runTests, normalMode, OutPath, debug);
    if (estimatedBestBuddiesCorrectness_ > currentBestBuddies)
        directCompVal{n} = directCompVal_;
        neighborCompVal{n} = neighborCompVal_;
        estimatedBestBuddiesCorrectness{n} = estimatedBestBuddiesCorrectness_;
        estimatedAverageOfProbCorrectness{n} = estimatedAverageOfProbCorrectness_;
        solutionPartsOrder{n} = solutionPartsOrder_;
        segmentsAccuracy{n} = segmentsAccuracy_;
        numOfIterations{n} = numOfIterations_;
        
        currentBestBuddies = estimatedBestBuddiesCorrectness_;
    end
    i
    if ShowSubResults
        figure; 
        imshow(combinePieces(Pieces, pw,ph ,solutionPartsOrder{n}))
        title(['Noise level: ', num2str(n), '  Iteration Number:', num2str(i)]);
    end
end
end

%
fileID = fopen([OutPath, ImFilename, '_partSize=', num2str(partSize), '_Noise', '.txt'],'w');
switch NoiseType
    case {1,2}
        noiseLevels = nLevel*(0:(N-1));
        fprintf(fileID,'Noise Levels:\r\n');
        fprintf(fileID,'%d %d %d %d %d %d\r\n', noiseLevels);
        fprintf(fileID,'\r\n');
        fprintf(fileID,'directCompVal:\r\n');
        fprintf(fileID,'%f %f %f %f %f %f\r\n', directCompVal{:});
        fprintf(fileID,'\r\n');
        fprintf(fileID,'neighborCompVal:\r\n');
        fprintf(fileID,'%f %f %f %f %f %f\r\n', neighborCompVal{:});
        fprintf(fileID,'\r\n');
        fprintf(fileID,'estimatedBestBuddiesCorrectness:\r\n');
        fprintf(fileID,'%f %f %f %f %f %f\r\n', estimatedBestBuddiesCorrectness{:});
        fprintf(fileID,'\r\n');
        fprintf(fileID,'estimatedAverageOfProbCorrectness:\r\n');
        fprintf(fileID,'%f %f %f %f %f %f\r\n', estimatedAverageOfProbCorrectness{:});
        fprintf(fileID,'\r\n');
        fprintf(fileID,'segmentsAccuracy:\r\n');
        fprintf(fileID,'%f %f %f %f %f %f\r\n', segmentsAccuracy{:});
        fprintf(fileID,'\r\n');
        fprintf(fileID,'numOfIterations:\r\n');
        fprintf(fileID,'%f %f %f %f %f %f\r\n', numOfIterations{:});
        fprintf(fileID,'\r\n');
    case {3,4,5}
        noiseLevels = nLevel*(0:(N-1));
        fprintf(fileID,'Noise Levels:\r\n');
        fprintf(fileID,'%d %d\r\n', noiseLevels);
        fprintf(fileID,'\r\n');
        fprintf(fileID,'directCompVal:\r\n');
        fprintf(fileID,'%f %f\r\n', directCompVal{:});
        fprintf(fileID,'\r\n');
        fprintf(fileID,'neighborCompVal:\r\n');
        fprintf(fileID,'%f %f\r\n', neighborCompVal{:});
        fprintf(fileID,'\r\n');
        fprintf(fileID,'estimatedBestBuddiesCorrectness:\r\n');
        fprintf(fileID,'%f %f\r\n', estimatedBestBuddiesCorrectness{:});
        fprintf(fileID,'\r\n');
        fprintf(fileID,'estimatedAverageOfProbCorrectness:\r\n');
        fprintf(fileID,'%f %f\r\n', estimatedAverageOfProbCorrectness{:});
        fprintf(fileID,'\r\n');
        fprintf(fileID,'segmentsAccuracy:\r\n');
        fprintf(fileID,'%f %f\r\n', segmentsAccuracy{:});
        fprintf(fileID,'\r\n');
        fprintf(fileID,'numOfIterations:\r\n');
        fprintf(fileID,'%f %f\r\n', numOfIterations{:});
        fprintf(fileID,'\r\n');
end
fclose(fileID);

for i=2:N
    switch NoiseType
        case 1
           ImPath{i} = [OutPath, ImFilename, '_nLevel=', num2str((i-1)*nLevel), '_result.jpg'];
        case 2
           ImPath{i} = [OutPath, ImFilename, '_nLevel=', num2str(100*(i-1)/nLevel), '_result.jpg']; 
        case 3
           ImPath{1} = [OutPath, ImFilename, '_Original_result.jpg'];
           ImPath{2} = [OutPath, ImFilename, '_Poisson_result.jpg'];
        case 4
           ImPath{1} = [OutPath, ImFilename, '_Original_result.jpg'];
           ImPath{2} = [OutPath, ImFilename, '_Rotate_result.jpg'];
        case 5
           ImPath{1} = [OutPath, ImFilename, '_Original_result.jpg'];
           ImPath{2} = [OutPath, ImFilename, '_Light_result.jpg'];
    
    end
    clear Pieces;
    for m=0:(ph-1)
        for k=1:pw
            Pieces{m*pw+k}.Data = uint8(Im{i}(m*partSize+1:(m+1)*partSize,(k-1)*partSize+1:k*partSize,:));
        end
    end
    
    % Save the resulting image, to be used as input for the algorithm 
    imwrite(uint8(combinePieces(Pieces, pw,ph ,solutionPartsOrder{i})), ImPath{i});
end

save([OutPath, ImFilename, '_partSize=', num2str(partSize), '_Noise', '.mat'], 'directCompVal', 'neighborCompVal', 'estimatedBestBuddiesCorrectness', 'estimatedAverageOfProbCorrectness', 'solutionPartsOrder', 'segmentsAccuracy', 'numOfIterations', 'noiseLevels');
end