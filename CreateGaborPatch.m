function gabor = CreateGaborPatch(window, size, sf, phase, contrast, orientation, aspectRatio, background)
% Create a Gabor patch image
%
% window - the window pointer
% size - the size of the patch in pixels
% sf - the spatial frequency of the grating in cycles per pixel
% phase - the phase of the grating in radians
% contrast - the contrast of the grating (0 to 1)
% orientation - the orientation of the grating in degrees
% aspectRatio - the aspect ratio of the Gabor patch (width/height)
% background - the background color of the patch

% Convert the orientation to radians
orientation = orientation * pi / 180;

% Generate the parameters for the Gabor patch
sigma = size / 8;  % the standard deviation of the Gaussian window
theta = orientation;  % the orientation of the grating
lambda = 1 / sf;  % the wavelength of the grating
psi = phase;  % the phase of the grating
gamma = aspectRatio;  % the aspect ratio of the Gabor patch
contrast = contrast;  % convert the contrast to a range of 0-255

% Generate the Gabor patch using the Psychtoolbox CreateProceduralGabor function
gabor = CreateProceduralGabor(window, size, size, [], background, 0, contrast);
gabor = gabor.*CreateGabor(theta, lambda, psi, gamma, sigma, size, size);
end