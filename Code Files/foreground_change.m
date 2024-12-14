v = VideoReader('tom_test.mp4');
fr = readFrame(v);
[M,N,k] = size(fr);
L = v.NumFrames;
V = zeros(L,M,N,k);

V(1,:,:,:) = rgb2ycbcr(fr);
n = 2;
while hasFrame(v)
    fr = readFrame(v);
    if(n==20)
        F2 = fr;
    end
    fr = rgb2ycbcr(fr);
    V(n,:,:,:) = rgb2ycbcr(fr);
    n = n+1;
end
%% 
t1 =20;
t2 =3;
tag = zeros(M,N);
vals = zeros(M,N);
F1 = imgaussfilt(squeeze(V(20,:,:,:)));
for i=2:6
    F = imgaussfilt(squeeze(V(i+19,:,:,:)));
    temp_val = abs(F-F1);
    imshow(uint8(temp_val));
    vals(:,:) = sum(temp_val,3);
end
for i=1:M
    for j =1:N
        vec = vals(i,j);
        m = max(vec);
        if(m >= t1)
            tag(i,j) = 1;
        elseif(m<t1 && m>t2)
            tag(i,j) = 1;
        end
    end
end

%% 
tag(tag<0) = 0;
mask = bwmorph(tag,'clean');
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
out = insertShape(F2, 'Rectangle', bbox, 'LineWidth', 3, 'Color', 'red');
imshow(out);
%imshow(F2);

subplot(1,2,2)
imshow(255*uint8(mask));

