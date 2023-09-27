function gabor = CreateGabor(theta, lambda, psi, gamma, sigma, width, height)
% Create a 2D Gaussian window
%
% theta - the orientation of the Gaussian window in radians
% lambda - the wavelength of the Gaussian window in pixels
% psi - the phase of the Gaussian window in radians
% gamma - the aspect ratio of the Gaussian window
% sigma - the standard deviation of the Gaussian window
% width - the width of the image in pixels
% height - the height of the image in pixels

% Generate the meshgrid for the Gaussian window
x0 = (width+1)/2;
y0 = (height+1)/2;
[X,Y] = meshgrid(1:width, 1:height);
X = (X - x0) * cos(theta) + (Y - y0) * sin(theta);
Y = -(X - x0) * sin(theta) + (Y - y0) * cos(theta);

% Generate the Gaussian window
gabor = exp(-(X.^2 + gamma.^2 * Y.^2) / (2 * sigma^2)) .* cos(2*pi*X/lambda + psi);
end