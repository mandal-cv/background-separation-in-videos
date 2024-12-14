v = VideoReader('tom_test.mp4');
K = v.NumFrames;
M = v.Height;
N = v.Width;
detector = vision.ForegroundDetector(...
       'NumTrainingFrames', 40, ...
       'InitialVariance', 30*30);
   
blob = vision.BlobAnalysis(...
       'CentroidOutputPort', false, 'AreaOutputPort', false, ...
       'BoundingBoxOutputPort', true, ...
       'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 1000);
   
shapeInserter = vision.ShapeInserter('BorderColor','White');

videoPlayer = vision.VideoPlayer();
i = 1;
V = zeros(K,M,N,3);
mask = zeros(K,M,N);

while hasFrame(v)
     frame  = readFrame(v);
     fgMask = detector(frame);

     V(i,:,:,:) = frame;
     mask(i,:,:) = fgMask;

     bbox   = blob(fgMask);
     out    = shapeInserter(frame,bbox);
     videoPlayer(fgMask);
     pause(0.1);
     
end

%% morphological processing
[M,N] = size(mask);
mask = bwmorph(mask,'clean');
mask = bwmorph(mask,'spur');
mask = bwmorph(mask, 'open');
mask = bwareaopen(mask, M*N/200);
mask = bwmorph(mask, 'close', 10);
mask = bwmorph(mask, 'thicken', 10);
mask = bwmorph(mask, 'fill',2);
mask = bwmorph(mask, 'close');
mask = imfill(mask,'holes');
imshow(255*uint8(mask));

%% 
subplot(1,2,1)
blob = vision.BlobAnalysis(...
       'CentroidOutputPort', false, 'AreaOutputPort', false, ...
       'BoundingBoxOutputPort', true, ...
       'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 500);
bbox = blob(mask);
out = insertShape(F, 'Rectangle', bbox, 'LineWidth', 3, 'Color', 'red');
imshow(out);
% imshow(F);

subplot(1,2,2)
imshow(255*uint8(mask));
