function [] = bytesize(v)
% where v is the actual variable you want measured.
% EXAMPLE:  syze(v) not syze('v')

x=v;

w=whos('x'); 

fprintf('\n\nShape:  %s  ', num2str(size(x)))
fprintf('\nClass:  %s ', class(x) )
fprintf('\n\n--BYTES--')
fprintf('\n  %2.0f Kb ', (w.bytes/1024) )
fprintf('\n  %2.2f Mb ', (w.bytes/1024^2) )
fprintf('\n  %4.5f Gb \n\n', (w.bytes/1024^3) )



% TO GET THE SIZE OF A TIFF IMAGE STACK
% prod(size(v))*8/(2^30)
%
% if isa(v,'single')||isa(v,'double')
%     sz = realmax(class(v));
% else
%     sz = intmax(class(v));
%     prod(size(x))*8/(2^30)
% end


% varargout = {w};
end