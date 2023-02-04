function [result] = DCT_kwantyzacja(colour, quantization_matrix)

% dzielenie bloków na 8x8 pikseli i poddawanie ich działaniu DCT
colour = blkproc(colour, [8 8], 'dct2(x)');
% określanie liczby bloków i zaokrąglenie jej w górę
colour = blkproc(colour, [8 8], 'round(x./P1)', quantization_matrix);
colour = colour + 128.0; 
% zwracana skwantowanej macierzy
result = colour;

end