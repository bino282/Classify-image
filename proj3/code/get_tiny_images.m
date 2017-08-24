% Starter code prepared by James Hays for CS 143, Brown University

%This feature is inspired by the simple tiny images used as features in 
%  80 million tiny images: a large dataset for non-parametric object and
%  scene recognition. A. Torralba, R. Fergus, W. T. Freeman. IEEE
%  Transactions on Pattern Analysis and Machine Intelligence, vol.30(11),
%  pp. 1958-1970, 2008. http://groups.csail.mit.edu/vision/TinyImages/

function image_feats = get_tiny_images(image_paths)
% image_paths is an N x 1 cell array of strings where each string is an
%  image path on the file system.
% image_feats is an N x d matrix of resized and then vectorized tiny
%  images. E.g. if the images are resized to 16x16, d would equal 256.

% To build a tiny image feature, simply resize the original image to a very
% small square resolution, e.g. 16x16. You can either resize the images to
% square while ignoring their aspect ratio or you can crop the center
% square portion out of each image. Making the tiny images zero mean and
% unit length (normalizing them) will increase performance modestly.

% suggested functions: imread, imresize
%GET_TINY_IMAGES Returns resized square images in a vectorised form
%   output:
%       tiny_images =   an N x d matrix of resized and then vectorized tiny
%                       images. The d is based on dimensionSize and COLOUR.
%                       E.g when dimensionSize = 16, COLOUR = 'rgb'
%                       d = 16 x 16 x 3
%                       For COLOUR ='greyscale'
%                       d = 16 x 16 x 1
%               
%   parameters:
%       images_path =   an N x 1 cell array of strings where each string is an
%                       image path on the file system.
%       dimensionSize = dimension size of a tiny image after resizing. E.g.
%                       in case of a 16x16 dimensionSize is 16. Feature
%                       size is dimensionSize * dimensionSize
%       method =        method to use when resizing. Can be either
%                       'center-crop' or 'fit'. 'center-crop' will first
%                       crop the original picture to a square whose center
%                       aligns with the picture's center
%                       'fit' will resize the original picture ignoring
%                       original aspect ratio
%       normalise =     'unit variance' - all images normalised to zero mean
%                       unit variance. 
%                       'unit_length' - all images normalised to zero mean
%                       and unit length
%                       'none' - normalisation is performed
%       colour =        'greyscale', 'rgb'
dimensionSize=16;
METHOD='center-crop';
NORMALISE='unit variance';
COLOUR='greyscale';

display('Getting tiny images');
noImages = length(image_paths);


switch(COLOUR)
    case 'greyscale'
        planes = 1;
    case 'rgb'
        planes = 3;
end
featureSize = dimensionSize * dimensionSize * planes;
dimensions = [dimensionSize,dimensionSize];

image_feats = zeros(noImages,featureSize);

for i=1:noImages
    img = imread(image_paths{i});
    
    %   GREYSCALE OR RGB
    switch COLOUR
        case 'rgb'
            img = rgb2gray(img);
        case 'greyscale'
            % do nothing, the image is already colour
    end
    
    %   choose method of resizing
    switch METHOD
        case 'center-crop'
            % create square that is centered and fills
            % the most of the original image
            
            [y,x,planes] = size(img);
            
            % not a square - crop
            if x~=y
                if x<y
                    squareSize = x;
                    bigger = y;
                else
                    squareSize = y;
                    bigger = x;
                end
            
            
            center = [x/2,y/2];
            
            if bigger == x
            topLeftCorner = [center(1)-squareSize/2,1];
            else
            topLeftCorner = [1,center(2)+squareSize/2];
            end
            
            cropArea = [topLeftCorner(1),topLeftCorner(2),squareSize,squareSize];
            
            imgMod = imcrop(img,cropArea);
            imgMod = imresize(imgMod,dimensions);
            else
                %already a square - just resize
                imgMod = imresize(img,dimensions);
            end
            
            
           
                        
        case 'fit'
            imgMod = imresize(img,dimensions);
                        
    end
    
    %   vectorise
    imgMod = imgMod(:);
    
    %   cast to double
    imgMod = double(imgMod);
    
    %   normalising
    switch NORMALISE
        case 'unit-variance'
            % zero mean
            imgMod = imgMod - mean2(imgMod);
            % unit variance
            imgMod = imgMod/std2(imgMod);
            
        case 'unit-length'
            % zero mean
            imgMod = imgMod - mean2(imgMod);
            % unit length
            imgMod = imgMod/norm(imgMod);
        case 'none'
            % no normalisation
    end
    
    image_feats(i,:) = imgMod';
    
    
end






