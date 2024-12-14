vid = 'test4.mp4';

v = VideoReader(vid);
frate = v.FrameRate;    
height = v.Height/4;
width = v.Width/4;
n_frames = v.NumFrames;

% vectorize every frame to form matrix X
X = zeros(n_frames, height*width);
for i = (1:n_frames)
    frame = read(v, i);
    frame = imresize(rgb2gray(frame),0.25);
    X(i,:) = reshape(frame,[],1);
end

% apply Robust PCA
lambda = 1/sqrt(max(size(X)));
tic
[L,S] = RPCA_ADMM(X, lambda/3, 10*lambda/3, 1e-5);
toc
%% 

% prepare the new movie file
vidObj = VideoWriter('RobustPCA_video_output_test4.avi');
vidObj.FrameRate = frate;
open(vidObj);
range = 255;
map = repmat((0:range)'./range, 1, 3);
S = medfilt2(S, [5,1]); % median filter in time
for i = (1:size(X, 1))
    frame1 = reshape(X(i,:),height,[]);
    frame2 = reshape(L(i,:),height,[]);
    frame3 = reshape(abs(S(i,:)),height,[]);
    % median filter in space; threshold
    frame3 = (medfilt2(abs(frame3), [5,5]) > 5).*frame1;
    % stack X, L and S together
    frame = mat2gray([frame1, frame2, frame3]);
    frame = gray2ind(frame,range);
    frame = im2frame(frame,map);
    writeVideo(vidObj,frame);
end
close(vidObj);
