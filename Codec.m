clear;
close all;

in_img = imread('Miasto.jpg');
[oryginal_row, oryginal_column, oryginal_colour] = size(in_img);

% transformacja pikseli z modelu przestrzeni RGB do modelu przestrzeni YCbCr
img_in_ycbcr = rgb2ycbcr(in_img);

% pobranie liczby wierszy i kolumn 
[row, column, colour] = size(img_in_ycbcr);

% liczba rzędów i kolumn jest zaokrąglana w górę a następnie rozszerzana do wielokrotności 8
%8x8
all_rows = ceil(row/8) * 8; 
all_columns = ceil(column/8) * 8; 

% pobieranie składowych kolorów
Y  = img_in_ycbcr(:, :, 1);                   
Cb = zeros(all_rows/2, all_columns/2);       
Cr = zeros(all_rows/2, all_columns/2);       

for i = 1 : all_rows/2
% kolumna nieparzysta
    for j = 1 : 2 : (all_columns/2) - 1 
       Cb(i, j) = double(img_in_ycbcr(i*2 - 1, j*2 - 1, 2));     
       Cr(i, j) = double(img_in_ycbcr(i*2 - 1, j*2 + 1, 3));     
    end
% kolumna parzysta   
    for j = 2 : 2 : (all_columns/2)       
       Cb(i, j) = double(img_in_ycbcr(i*2 - 1, j*2 - 2, 2));     
       Cr(i, j) = double(img_in_ycbcr(i*2 - 1, j*2,     3));     
    end
end

% kodowanie składowych koloru

% tabela kwantyzacji luminancji - informacje o jasności
luminacja = [ 16  11  10  16   24   40    51  61
              12  12  14  19   26   58   60   55
              14  13  16  24   40   57   69   56
              14  17  22  29   51   87   80   62
              18  22  37  56   68  109  103   77
              24  35  55  64   81  104  113   92
              49  64  78  87  103  121  120  101
              72  92  95  98  112  100  103   99 ];
  
% tabela kwantyzacji chrominancji - informacje o różnicy kolorów
chrominancja = [ 17,  18,  24,  47,  99,  99,  99,  99;
           18,  21,  26,  66,  99,  99,  99,  99;
           24,  26,  56,  99,  99,  99,  99,  99;
           47,  66,  99,  99,  99,  99,  99,  99;
           99,  99,  99,  99,  99,  99,  99,  99;
           99,  99,  99,  99,  99,  99,  99,  99;
           99,  99,  99,  99,  99,  99,  99,  99;
           99,  99,  99,  99,  99,  99,  99,  99 ];

% odwrotna transformata kosinusowa i kwantyzacja dla trzech kanałów osobno
Y_dct_q  = DCT_kwantyzacja(Y,  luminacja);
Cb_dct_q = DCT_kwantyzacja(Cb, chrominancja);
Cr_dct_q = DCT_kwantyzacja(Cr, chrominancja);

% generowanie słownika Huffmana i kodu dla każdej składowej
I1 = floor(Y_dct_q(:));
dictY = slownik(Y_dct_q);
encoY = huffmanenco(I1, dictY); 

I2 = floor(Cb_dct_q(:));
dictCb = slownik(Cb_dct_q);
encoCb = huffmanenco(I2, dictCb); 

I3 = floor(Cr_dct_q(:));
dictCr = slownik(Cr_dct_q);
encoCr = huffmanenco(I3, dictCr); 

% zapis kodu huffmana i słownika do pliku
save('skompresowany_obraz.JMJ', 'dictY', 'encoY', 'dictCb', 'encoCb', 'dictCr', 'encoCr', '-mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%KONIEC KODERA 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%POCZĄTEK DEKODERA

% odczyt kodu huffmana i słowników
odczyt = load('skompresowany_obraz.JMJ', '-mat');

% dekodowanie kodu Huffmana 
decoY  = col2im(huffmandeco(odczyt.encoY,  odczyt.dictY),  [row, column],     [row, column],     'distinct');
decoCb = col2im(huffmandeco(odczyt.encoCb, odczyt.dictCb), [row/2, column/2], [row/2, column/2], 'distinct');
decoCr = col2im(huffmandeco(odczyt.encoCr, odczyt.dictCr), [row/2, column/2], [row/2, column/2], 'distinct');

% dekwantyzacja i odwrotna transformata cosinusowa dla każdego z kanałów
inv_Y  = odwrotna_DCT_i_kwantyzacja(decoY,  luminacja);
inv_Cb = odwrotna_DCT_i_kwantyzacja(decoCb, chrominancja);
inv_Cr = odwrotna_DCT_i_kwantyzacja(decoCr, chrominancja);

% % odzyskiwanie obrazu YCbCr
YCbCr_out_img(:, :, 1) = inv_Y;

for i=1:all_rows/2
   for j=1:all_columns/2
       
       YCbCr_out_img(2*i - 1, 2*j - 1, 2) = inv_Cb(i, j);
       YCbCr_out_img(2*i - 1, 2*j,     2) = inv_Cb(i, j);
       YCbCr_out_img(2*i, 2*j - 1, 2) = inv_Cb(i, j);
       YCbCr_out_img(2*i, 2*j,     2) = inv_Cb(i, j); 
       
       YCbCr_out_img(2*i - 1, 2*j - 1, 3) = inv_Cr(i, j);
       YCbCr_out_img(2*i - 1, 2*j,     3) = inv_Cr(i, j);
       YCbCr_out_img(2*i, 2*j - 1, 3) = inv_Cr(i, j);
       YCbCr_out_img(2*i, 2*j,     3) = inv_Cr(i, j);
       
   end
end
out = ycbcr2rgb(YCbCr_out_img);
figure(1)
imshow(in_img);
title('Obraz startowy'); 
figure(2)
imshow(out);
title('Obraz po kompresji i dekompresji');

imwrite(out, 'efekt_koncowy.jpg')

X = imread('efekt_koncowy.jpg');
B = immse(X, in_img);
disp(strcat(['Błąd średniokwadratowy: ' num2str(B)]));
figure(3)
imshow(in_img-out);
