function result = encode(signal, im)
	signal = uint8(255*(signal + 0.5));% convert signal from double to uint8
	[r, c]    = size(im);%dimensions of image
	imBitsL      = length(im(:))*8; %bits length of image
	
	signalBits = dec2bin(signal, 8);%signal in bits
	imBits = dec2bin(im(:), 8);%image in bits
	im1D = zeros(imBitsL, 1);%recipient for image in 1 dimension

	for i = 1:8%writes image in 1D with bits
		for j = 1:length(im(:))
			k   = (i-1)*length(im(:)) + j;
			im1D(k, 1) = str2double(imBits(j, i));
		end
	end

	for i = 1:imBitsL%writes information on less significant bits of the signal                  
		signalBits(i, 8) = dec2bin(im1D(i)); 
	end 

	signal = bin2dec(signalBits);
	signal = (double(signal)/255 - 0.5);
	result = signal;