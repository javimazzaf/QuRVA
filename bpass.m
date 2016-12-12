% 		Implements a real-space bandpass filter to suppress pixel noise and
%       slow-scale image variations while retaining information of a characteristic size.
% 		*Works with anisotropic 3d cube data*
% 		simple 'mexican hat' wavelet convolution yields spatial bandpass filtering.
%
%  CALLING SEQUENCE:
% 		res = bpass(img, nsz, hspsz)
%  INPUTS:
% 		img:	two-dimensional array to be filtered.
% 		nsz: characteristic lengthscale of noise in pixels. Additive noise averaged
%                   over this length should vanish. May assume any positive floating value.
% 			Make it a 3-vector if aspect ratio is not 1:1:1.
% 		hspsz: A length in pixels somewhat larger than *half* a typical object. Must be an odd valued
%                   integer. Make it a 3-vector if aspect ratio is not 1:1:1.
%  OUTPUTS:
% 		res:	filtered image.

function res = bpass(img,nsz,hspsz)

img   = double(img);
nsz   = double(nsz);
hspsz = round(max(hspsz,2*nsz));

%Detail scale remove filter
dsf = exp(-(-hspsz:hspsz).^2/2/nsz^2);
dsf = dsf / sum(dsf);

%corse scale remove filter
csf = exp(-(-hspsz:hspsz).^2/2/hspsz^2);
csf = csf / sum(csf);

%Do filtering
ds_im = conv2(dsf,dsf',img,'valid');
cs_im = conv2(csf,csf',img,'valid');
res = ds_im-cs_im;
res = max(res,0);

%Zeropad result to input size
tmp = 0 * img;
rval = hspsz+1 : size(res,1)+hspsz;
cval = hspsz+1 : size(res,2)+hspsz;

tmp(rval,cval)=res;

res=tmp;

end
