function imFiltered = imgfilt(im,sigma)

hsz = 2 * ceil(2 * sigma) + 1;

imFiltered = filter2(fspecial('gaussian',hsz,sigma), im,'same');

end