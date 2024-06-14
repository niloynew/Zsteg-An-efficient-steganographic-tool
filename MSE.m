% //////////////////////////////////////
% Authors
% 1. Zinia Sultana
% ID: 201314059
% Computer Science And Enggineering
% Military Institute of Science and Technology
% Mirpur, Dhaka, Bangladesh

% 2. Niloy Roy
% 3. Sadman Saumik 
% Computer Science And Enggineering
% Military Institute of Science and Technology
% Mirpur, Dhaka, Bangladesh

% Sepecial Thanks to the Author who have 
% implemented AES-128,192,256 encryption/ decryption function
% //////////////////////////////////////

clc
clear all

[ filename , filepath ] = uigetfile({'*.bmp'},'Select Cover image');
 path1 = [filepath filename];
 
 [ filename , filepath ] = uigetfile({'*.bmp';'*.tiff';'*.tif'},'Select Stego image');
 path2 = [filepath filename];
 
 X = imread(path1);
 Y = imread(path2);
 
 A = X(:,:,3);
 B = Y(:,:,3);
 
 
 [row, col] = size(A);
 
 pixel_num = row * col;
 sum = 0;
 for i = 1: pixel_num
     
     a = A(i) - B(i);
     b = a * a;
     sum = sum + b;
 end
 
 mse = double(sum) / double(pixel_num) ;
 disp(mse);
 
 figure;
 subplot(1,2,1),imshow(X); xlabel( 'cover.bmp');
 title('Calculating the Mean Square Error ( MSE ):');
 subplot(1,2,2),imshow(Y); xlabel( 'stego.bmp');
 title(mse);
 
 
 
 
 
 
 
 
 
 
 
%  imwrite(X,'stego.bmp');
%  C = imread('stego.bmp');
%  
%  figure;
%  subplot(1,2,1),imshow(X); xlabel( 'cover.bmp');
%  title('Calculating the Mean Square Error: ');
%  subplot(1,2,2),imshow(Y); xlabel( 'stego.bmp');
 

 


 
