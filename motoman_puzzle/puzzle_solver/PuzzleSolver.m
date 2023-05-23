clc;
clear all;
close all;

showRoughBlockSeparation = true;
showFinalPiecesBeforeSolving = true;
showOnlyBestEstimatedSolution = false;
showEachPiece = 2;  % 0 - no output
                                             % 1 - only piece rotation and cropping
                                             % 2 - also show step identifying each piece closely
PieceCornerMethod = 3;  % choose 1, 2 or 3


% Read image and normalize size using SIZE constant
SIZE = 800;
Im = imread('Images\Casspi_16_new_3.JPG');
factor = SIZE/min(size(Im, 1), size(Im,2));
Im = imresize(Im, factor);

%% Separate image into rough segments, each containing one piece 
Pieces = SeparatePieces(Im, showRoughBlockSeparation);


%% Detect each piece's area more closely
Pieces = TightCropRotate(Pieces, PieceCornerMethod, showEachPiece);


%% Find minimum piece size, use it to standardize pieces
pSize = SIZE;
for m=1:size(Pieces,1)
    temp = min(size(Pieces{m}, 1), size(Pieces{m}, 1));
    if (temp < pSize)
        pSize = temp;
    end
end





%%
% ============================================================
% Loop: Crop pixels from all sides, run the algorithm. Save best result
% ============================================================

Pieces_Orig = Pieces;
bestBestBuddies = 0;
bestSol = [];
for k=floor(SIZE/400):(3+floor(SIZE/400))
currentBestBuddies = 0;

% Crop a little from each piece and resize to standard piece size
p2c = k; % Pixels to crop from every side

for m=1:size(Pieces,1)
    p = Pieces_Orig{m};
    Pieces{m} = p((1+p2c):(end-p2c), (1+p2c):(end-p2c), :);
    Pieces{m} = imresize(Pieces{m}, [pSize,pSize]);
end


% Combine pieces to a single image
a = sqrt(size(Pieces,1));
puzzleInput = combinePieces(Pieces, a, a, (1:a*a));

if showFinalPiecesBeforeSolving
    figure;
    imshow(puzzleInput);
end

% Save the resulting image, to be used as input for the algorithm 
imwrite(puzzleInput, 'pic2algo.jpg')

%%
% Run the algorithm
ImPath = 'pic2algo.jpg';
OutPath = 'Output\';

firstPartToPlace = -1; % random seed
partSize = pSize; % A square part size, this size should divide with the image
                                          % size or the image is cropped.
compatibilityFunc = 1; % Prediction-based Compatibility (Default)
% shiftMode = 1; % Move largest segment across all possible locations and take the best placement
shiftMode = 2; % Growing largest segment using estimationFunc  estimation metric to 
                                % measure convergence (Default)
colorScheme = 0; % RGB
greedyType = 3; % Narrow Best Buddies with average (Default)
estimationFunc = 0; % Best Buddies (Default)
outputMode = 0; % None (only return values)
runTests = 0;
normalMode = 4; % Exponent according to first quartile value (Default)
resPath = OutPath;
debug = 0; % Off

% 20 iterations
% Save best solution so far according to "Best Buddies" estimation metric.
for i=1:20
    [directCompVal, neighborCompVal, estimatedBestBuddiesCorrectness, estimatedAverageOfProbCorrectness, solutionPartsOrder, segmentsAccuracy, numOfIterations] = JigsawSolver(ImPath, firstPartToPlace, partSize, compatibilityFunc, shiftMode, colorScheme, greedyType, estimationFunc, outputMode, runTests, normalMode, OutPath, debug);
    if (estimatedBestBuddiesCorrectness > currentBestBuddies)
        sol = solutionPartsOrder;
        currentBestBuddies = estimatedBestBuddiesCorrectness;
        k_opt = k;
    end
end


if showOnlyBestEstimatedSolution
    if bestBestBuddies < currentBestBuddies
        bestBestBuddies = currentBestBuddies;
        bestSol = sol;
    end
else
    % Arrange puzzle according to best solution found and display
    puzzleOutput = combinePieces(Pieces, a, a, sol);
    figure;
    imshow(puzzleOutput);
    title(['Best Buddies estimate: ', num2str(currentBestBuddies)]);
end

k
currentBestBuddies
end

if showOnlyBestEstimatedSolution
    % Arrange puzzle according to best solution found and display
    puzzleOutput = combinePieces(Pieces, a, a, sol);
    figure;
    imshow(puzzleOutput);
    title(['Best Buddies estimate: ', num2str(currentBestBuddies)]);
end