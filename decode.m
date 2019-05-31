function result = decode(signal,imDim)

	signal  = uint8(255*(signal + 0.5)); %double values to uint8

	imNbPixels = imDim^2; %image has the same x and y dimensions
	imNbBits = imNbPixels * 8; %number of bits in image


	signalBits = dec2bin(signal, 8);%signal in bits
	imBits1D = signalBits(1:imNbBits, 8);%retrieves each less significant bit
	imBits    = reshape(imBits1D, imNbPixels , 8);%image as an array of 8-bits cases
	im1D    = zeros(imNbPixels, 1, 'uint8');%recipient of the image in 1D with uint8 values

	for i = 1 : imNbPixels% convert bits in decimal values
		im1D(i,1) = bin2dec(imBits(i, :));
	end

	im = reshape(im1D, imDim , imDim);%reshape the 1D image in a imDim x imDim image, in our case 42x42

	result = im; 