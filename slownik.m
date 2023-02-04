%słownik kompresora Huffmana
function result = huffman(colour)

[M, N] = size(colour);

I = floor(colour(:));
P = zeros(1, 256);

for i = 0:255
     P(i + 1) = length(find(I == i))/(M * N);
end

k = 0:255;

result = huffmandict(k, P);

end