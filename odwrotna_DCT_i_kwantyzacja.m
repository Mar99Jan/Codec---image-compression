function [result] = odwrotna_DCT_i_kwantyzacja(colour, quantization_matrix)

colour = colour - 128.0;
colour = blkproc(colour, [8 8], 'x.*P1', quantization_matrix);
% odwrotna DCT
colour = blkproc(colour, [8 8], 'idct2(x)');  
% macierz po dekwantyzacji oraz po odwrotnym DCT
result = colour/255;      

end