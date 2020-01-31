function [IMG] = IMPORTimages(PIX)

warning('off')
TifLink = Tiff(PIX.info.Filename{1}); 

for i=1:height(PIX.info)

    TifLink.setDirectory(i);
    IMG(:,:,i)=TifLink.read();

end
TifLink.close();


h = imagesc(IMG(:,:,1));
imattributes(h)





end