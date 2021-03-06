function [error, f] = GeoError(x, X, ks, K, Rs, ts)
% Measure a geometric error
%
%   x:  2D points. n x 2 x N matrix, where n is the number of corners in
%   a checkerboard and N is the number of calibration images
%       
%   X:  3D points. n x 2 matrix, where n is the number of corners in a
%   checkerboard and assumes the points are on the Z=0 plane
%
%   K: a camera calibration matrix. 3 x 3 matrix.
%
%   Rs: rotation matrices. 3 x 3 x N matrix, where N is the number of calibration images. 
%
%   ts: translation vectors. 3 x 1 x N matrix, where N is the number of calibration images. 
%
%   ks: radial distortion parameters. 2 x 1 matrix, where ks(1) = k_1 and
%   ks(2) = k_2.
%

%% Your code goes here
N = size(x,3);
n = size(x,1);
x_hat = zeros(N*n,2);

for i = 1:N
    ab_h = [Rs(:,:,i) ts(:,:,i)]*[X';zeros(1,n);ones(1,n)];
    ab_ih = bsxfun(@rdivide,ab_h(1:2,:),ab_h(3,:));
    r = sqrt(sum(ab_ih.^2));
    
    ab_dist = bsxfun(@times,ab_ih,1 + ks(1)*r.^2 + ks(2)*r.^4);
    est = K*[ab_dist; ones(1,n)];
    x_hat((i-1)*n+1:i*n,:) = bsxfun(@rdivide,est(1:2,:),est(3,:))';
end

x_res = zeros(N*n,2);
for i = 1:N
    x_res((i-1)*n+1:i*n,:) = x(:,:,i);
end
x_temp = x_res-x_hat;
error = sum(sum(x_temp.^2,2));
f = x_temp;
end