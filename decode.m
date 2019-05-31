function result = decode(signal,imDim)

	signal  = uint8(255*(signal + 0.5));  % double [-0.5 +0.5] to 'uint8' [0 255]

	imNbPixels = imDim^2; %image has the same x and y dimensions
	imNbBits = imNbPixels * 8; %number of bits in image


	signalBits = dec2bin(signal, 8);%signal in bits
	%% extract watermark
	imBits1D = signalBits(1:imNbBits, 8);%retrieves each less significant bit
	imBits    = reshape(imBits1D, imNbPixels , 8);%image as an array of 8-bits cases
	im1D    = zeros(imNbPixels, 1, 'uint8');%recipient of the image in 1D with non binary values
	for i     = 1:imNbPixels                        % extract water mark from the first plane of host               
		im1D(i, :) = bin2dec(imBits(i, :));      % Least Significant Bit (LSB)
	end
	im = reshape(im1D, imDim , imDim);
	%% show image
	%imshow(im)
	result = im; 