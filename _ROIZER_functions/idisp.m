function [] = idisp(I)

disp(' ')
fprintf('min: %-10.8g \n',min(I(:)))

fprintf('max: %2.8g \n',max(I(:)))

fprintf('mean: %2.8g \n',mean(I(:)))

fprintf('median: %2.8g \n',median(I(:)))




sz = size(I);
d = ndims(I);

if d == 2

fprintf('1D: %2.0f \n',sz(1))
fprintf('2D: %2.0f \n',sz(2))
disp(' ')

elseif d == 3

fprintf('1D: %2.0f \n',sz(1))
fprintf('2D: %2.0f \n',sz(2))
fprintf('3D: %2.0f \n',sz(3))
disp(' ')

elseif d == 4

fprintf('1D: %2.0f \n',sz(1))
fprintf('2D: %2.0f \n',sz(2))
fprintf('3D: %2.0f \n',sz(3))
fprintf('4D: %2.0f \n',sz(4))
disp(' ')

end

end