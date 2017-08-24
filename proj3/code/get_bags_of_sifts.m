% Starter code prepared by James Hays for CS 143, Brown University

%This feature representation is described in the handout, lecture
%materials, and Szeliski chapter 14.

function image_feats = get_bags_of_sifts(image_paths)
% image_paths is an N x 1 cell array of strings where each string is an
% image path on the file system.

% This function assumes that 'vocab.mat' exists and contains an N x 128
% matrix 'vocab' where each row is a kmeans centroid or visual word. This
% matrix is saved to disk rather than passed in a parameter to avoid
% recomputing the vocabulary every time at significant expense.

% image_feats is an N x d matrix, where d is the dimensionality of the
% feature representation. In this case, d will equal the number of clusters
% or equivalently the number of entries in each image's histogram.

% You will want to construct SIFT features here in the same way you
% did in build_vocabulary.m (except for possibly changing the sampling
% rate) and then assign each local feature to its nearest cluster center
% and build a histogram indicating how many times each cluster was used.
% Don't forget to normalize the histogram, or else a larger image with more
% SIFT features will look very different from a smaller version of the same
% image.

%{
Useful functions:
[locations, SIFT_features] = vl_dsift(img) 
 http://www.vlfeat.org/matlab/vl_dsift.html
 locations is a 2 x n list list of locations, which can be used for extra
  credit if you are constructing a "spatial pyramid".
 SIFT_features is a 128 x N matrix of SIFT features
  note: there are step, bin size, and smoothing parameters you can
  manipulate for vl_dsift(). We recommend debugging with the 'fast'
  parameter. This approximate version of SIFT is about 20 times faster to
  compute. Also, be sure not to use the default value of step size. It will
  be very slow and you'll see relatively little performance gain from
  extremely dense sampling. You are welcome to use your own SIFT feature
  code! It will probably be slower, though.

D = vl_alldist2(X,Y) 
   http://www.vlfeat.org/matlab/vl_alldist2.html
    returns the pairwise distance matrix D of the columns of X and Y. 
    D(i,j) = sum (X(:,i) - Y(:,j)).^2
    Note that vl_feat represents points as columns vs this code (and Matlab
    in general) represents points as rows. So you probably want to use the
    transpose operator '  You can use this to figure out the closest
    cluster center for every SIFT feature. You could easily code this
    yourself, but vl_alldist2 tends to be much faster.

Or:

For speed, you might want to play with a KD-tree algorithm (we found it
reduced computation time modestly.) vl_feat includes functions for building
and using KD-trees.
 http://www.vlfeat.org/matlab/vl_kdtreebuild.html

%}
bin_size = 3;
sigma_smooth = 1;
smoothing = 1;
colour = 'greyscale';
load('vocab.mat')
vocab_size = size(vocab, 2);
imgNo = length(image_paths);
step = 6;

%% temporary histogram for one image
imgHist = zeros(vocab_size,1);

image_feats = [];

for i =1 :imgNo
    
    img = imread(image_paths{i});
    img = single(img);
     if(strcmp(colour, 'greyscale'))
        %% convert to greyscale
        %img = rgb2gray(img);
    elseif (strcmp(colour, 'hsv'))
        %% convert to hsv
        img = rgb2hsv(img);
    elseif(strcmp(colour,'w-sift'))
        r = img(:,:,1);
        g = img(:,:,2);
        b = img(:,:,3);
        
        o1 = (r-g)/sqrt(2);
        o2 = (r+g-2*b)/sqrt(6);
        o3 = (r+ g + b)/sqrt(3);
        
        W1 = o1./o3;
        W2 = o2./o3;
        
        img = cat(3,W1,W2);
    
    end
    
    
    
    
    combinedHist = [];
    
    %% loop through planes for colour images
    for j = 1 : size(img,3)
        %% SIFT_features = d*M where M is num of features sampled , d = 128.
        imgPlane = img(:,:,j);
        
        
        if(smoothing ==1)
            %% smooth before extracting features
            [imgPlane] = vl_imsmooth(imgPlane,sigma_smooth);
        end
        
        [locations, SIFT_features] = vl_dsift(single(imgPlane),'step',step,'fast', 'size',bin_size);
        
        
        %% Local clustering
        D = vl_alldist2(vocab,single(SIFT_features));
        
        
        [mindist,indices] = min(D,[],1);
        
        %% build histogram
        for k = 1 : size(mindist,2)
            imgHist(indices(k)) = imgHist(indices(k))+1;
        end
        
        %% normalise histogram
        imgHistNorm = imgHist./size(SIFT_features,2);
        
        %% add to combined histogram
        combinedHist = [combinedHist;imgHistNorm];
    end
    
    combinedHist = combinedHist';
    %add histogram to feature list
    image_feats = [image_feats;combinedHist];
end
end



