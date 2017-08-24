% Starter code prepared by James Hays for CS 143, Brown University

%This function will predict the category for every test image by finding
%the training image with most similar features. Instead of 1 nearest
%neighbor, you can vote based on k nearest neighbors which will increase
%performance (although you need to pick a reasonable value for k).

function predicted_categories = nearest_neighbor_classify(train_image_feats, train_labels, test_image_feats,categories)
% image_feats is an N x d matrix, where d is the dimensionality of the
%  feature representation.
% train_labels is an N x 1 cell array, where each entry is a string
%  indicating the ground truth category for each training image.
% test_image_feats is an M x d matrix, where d is the dimensionality of the
%  feature representation. You can assume M = N unless you've modified the
%  starter code.
% predicted_categories is an M x 1 cell array, where each entry is a string
%  indicating the predicted category for each test image.

%{
Useful functions:
 matching_indices = strcmp(string, cell_array_of_strings)
   This can tell you which indices in train_labels match a particular
   category. Not necessary for simple one nearest neighbor classifier.

 D = vl_alldist2(X,Y) 
    http://www.vlfeat.org/matlab/vl_alldist2.html
    returns the pairwise distance matrix D of the columns of X and Y. 
    D(i,j) = sum (X(:,i) - Y(:,j)).^2
    Note that vl_feat represents points as columns vs this code (and Matlab
    in general) represents points as rows. So you probably want to use the
    transpose operator ' 
   vl_alldist2 supports different distance metrics which can influence
   performance significantly. The default distance, L2, is fine for images.
   CHI2 tends to work well for histograms.
 
  [Y,I] = MIN(X) if you're only doing 1 nearest neighbor, or
  [Y,I] = SORT(X) if you're going to be reasoning about many nearest
  neighbors 

%}
%nearest_neighbor_classify Using k-nearest neighbor algorithm predicts the
%       scene category for each image
%   returns:    Nx1 cell array where each cell corresponds to a predicted
%               category and N is the number of test images
%
%   parameters:
%       k = number of nearest neighbors considered
%       distanceType = function to be passed to the pdsit2 interface
%       @histogram_intersection, @chi_square statistics

k=4;
DISTANCE_TYPE='euclidean';
testDataLength = size(test_image_feats,1);
[trainDataLength,featuresSize] = size(train_image_feats);

predicted_categories = cell(testDataLength,1);

%uncomment to use standard distance computation
%distanceMatrix = pdist2(test_features,train_features,DISTANCE_TYPE);
distanceMatrix = pdist2(train_image_feats,test_image_feats,DISTANCE_TYPE);


for i=1:trainDataLength
    % FOR EVERY TEST IMAGE DISTANCE VECTOR
    % each row in distanceMatrix corresponds to the distances between one
    % test image and all train images
    
    % get k smallest values along with their indices (indice of a train image this image looks most like)
    
    [values, trainImgIndices] = getNElements(distanceMatrix(i,:),k);
    if i == 1000
        qs=10;
    end
        
    
    %  get category names from train image indices
    categoryNames = train_labels(trainImgIndices);
    
    %  get category indices from categoryNames
    categoryIndices = zeros(length(categoryNames),1);
    
    for n=1:length(categoryNames)
        categoryIndices(n) = find(strcmp(categories,categoryNames(n)));
    end
    
    %  get mode
    [isMode,modeValue] = getMode(categoryIndices);
    
    % if the mode does not exist - pick the first value (smallest distance)
    if isequal(isMode,false)
        predictedCatIndex = categoryIndices(1);
    else
        predictedCatIndex = modeValue;
    end
    
      
    predicted_categories(i,:) = categories(predictedCatIndex);
    
   
end











