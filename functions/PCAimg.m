function [IM] = PCAimg(IMG)
clc;

% FIRST RESHAPE IMAGE STACK INTO A SINGLE MATRIX
IM = reshape(IMG,  SZ.r*SZ.c,[]  );


% RUN PRINCIPAL COMPONENTS ANALYSIS
IM = single(IM);

[PC.coef,PC.score,~] = pca(IM');

[PC(2).coef,PC(2).score,~] = pca(IM);


% RESHAPE COEF BACK INTO A STACK
PC(1).imc = reshape( PC(1).coef , SZ.r , SZ.c , [] );
PC(1).imc = PC(1).imc(:,:,1:25); % GET THE FIRST 25 COMPONENTS

PC(2).ims = reshape( PC(2).score , SZ.r , SZ.c , [] );
PC(2).ims = PC(2).ims(:,1:25); % GET THE FIRST 25 COMPONENTS


end