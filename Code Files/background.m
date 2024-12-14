F1 = squeeze(V(1,:,:,:));
w = 9;
P = ceil(M/w);
Q = ceil(N/w);

MV = zeros(11,P,Q);
hbm = vision.BlockMatcher('ReferenceFrameSource',...
        'Input port','BlockSize',[w w], 'SearchMethod', 'Three-step' );
hbm.OutputValue = 'Horizontal and vertical components in complex form';
c =1;
for i=1:1:11
    Iref = imgaussfilt(uint8(squeeze(V(i,:,:,:))));
    I = imgaussfilt(uint8(squeeze(V(i+1,:,:,:))));
    MV(c,:,:) = hbm(im2double(rgb2gray(I)),im2double(rgb2gray(Iref)));
    c = c+1;
end

MVx = real(MV);
MVx(MVx>= 1 & MVx <= -1) = 0;
MVy = imag(MV);
MVy(MVy>= 1 & MVy <= -1) = 0;
%% 
halphablend = vision.AlphaBlender;
img12 = halphablend(uint8(squeeze(V(9,:,:,:))),uint8(squeeze(V(10,:,:,:))));
[X,Y] = meshgrid(1:w:size(F1,2),1:w:size(F1,1));         
imshow(img12)
hold on
mvx = squeeze(MVx(9,:,:)); mvy = squeeze(MVy(9,:,:));
quiver(X(:),Y(:),mvx(:),mvy(:),0)
hold off

%% 
fgMask = squeeze(mask(10,:,:));
% fgMask = mask;
%out = shapeInserter(fgMask,bbox);
fgMask = fgMask > 0;
fgMask = bwmorph(fgMask,'thicken',5);
blob = vision.BlobAnalysis(...
       'CentroidOutputPort', false, 'AreaOutputPort', false, ...
       'BoundingBoxOutputPort', true, ...
       'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 1000);

bbox = blob(fgMask);
% out = insertShape(255*uint8(fgMask), 'Rectangle', bbox);
out = insertShape(uint8(squeeze(V(10,:,:,:))), 'Rectangle', bbox);

imshow(out);
Bx = bbox(1);
By = bbox(2);
W = bbox(3);
H = bbox(4);

TLx = Bx;
TLy = By;
BRx = Bx + W;
BRy = By + H;
MVA = [];
w=11;
for i=1:w:720
    for j = 1:w:1280
        if(i>TLy && i<BRy && j>TLx && j<BRx)
            sumx = MVx(1,(i-1)/w,(j-1)/w);
            sumy = MVy(1,(i-1)/w,(j-1)/w);
            i1 = (i-1)/w;
            j1 = (j-1)/w;
            for k =2:10
                bx = j1+MVx(k,i1,j1);
                by = i1+MVy(k,i1,j1);
                sumx = sumx + MVx(k,by,bx);
                sumy = sumy + MVx(k,by,bx);
            end
            MVA = [MVA; sumx/10 sumy/10];
        end
    end
end


%%
Img = squeeze(V(10,:,:,:));
count = 1;
for i=1:w:720
    for j = 1:w:1280
        if(i>TLy && i<BRy && j>TLx && j<BRx)
            MVAx = MVA(count,1);
            MVAy = MVA(count,2);
            bx = j - (w-1)/2;
            by = i - (w-1)/2;
            Isx = 0;
            Isy = 0;
            if(MVAx > 0)
                MVAx = ceil(MVAx);
                Dx = bx - TLx;
            elseif(MVAx<0)
                MVAx = floor(MVAx);
                Dx = BRx - bx;
            end
            
            if(MVAy > 0)
                MVAy = ceil(MVAy);
                Dy = by - TLy;
            elseif(MVAy<0)
                MVAy = floor(MVAy);
                Dy = BRy - by;
            end
            
            if(MVAx ~= 0)
                Isx = (Dx + w)/MVAx;
            end
            
            if(MVAy ~= 0)
                Isy = (Dy + w)/MVAy;
            end
            
            Is = min(Isx,Isy);
            Img(by:by+2*w,bx:bx+2*w,:) = squeeze(V(Is,by:by+2*w,bx:bx+2*w,:));
            
            count = count+1;
        end
    end
end

imshow(uint8(Img))



