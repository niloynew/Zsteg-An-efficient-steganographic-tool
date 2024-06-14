% //////////////////////////////////////
% Authors
% 1. Niloy Roy
% Sepecial Thanks to the Author who have 
% implemented AES-128,192,256 encryption/ decryption function
% //////////////////////////////////////

clc 
clear all

%inputs secret message, image, password
%/////////////////////////////////////
 title = 'ZSteg';
 inputs={'Enter Your Secret Message' 'Password' };
 defaultans = {'****************','****************'};
 getinputs = inputdlg(inputs,title,[1 50; 1 50],defaultans);
 [ filename , filepath ] = uigetfile({'*.bmp'},'Select Cover image');
 image_path = [filepath filename];
%//////////////////////////////////////

%Setting key as multiple of 16
%//////////////////////////////
key = getinputs{2};
len_key = length(key);
key_extra = mod(len_key, 16);
key_add = 16 - key_extra;
add = char.empty(0,15);
for i=1 : 1:key_add
        add(i)= '*';
end
key = [key add];

%Setting sms as multiple of 16
%//////////////////////////////
sms = getinputs{1};
len_sms = length(sms);
sms_extra = mod(len_sms, 16);
sms_add = 16 - sms_extra;
add = char.empty(0,15);
for i=1 : 1:sms_add
        add(i)= '*';
end
sms = [sms add];

%Encrypting the sms using key
%//////////////////////////////
 sms = double(sms);
 key = double(key);
 s = aesinit(key);
 chipertext = aes(s,'encrypt','ecb', sms);
 disp(char(chipertext));
 %/////////////////////////////
 
 %Creatng stream of bnary data whch wll be embaded n mage
 %/////////////////////////////
 chipertext = dec2bin(chipertext);
 chiper_stream = reshape(chipertext',1,[]);
 len = length(chiper_stream);
 %/////////////////////////////
 
 


%To provide EOF= '00000' using bit stuffing inserting 1 after 4 zeros
%//////////////////////////////////
chiper_bit_stuffing = char.empty(0,1000);
count =0;
index=1;
for i=1: len
    if chiper_stream(i)== '0'
        count = count + 1;
        chiper_bit_stuffing(index) = chiper_stream(i);
        if count == 4
            index = index + 1;
            chiper_bit_stuffing(index) = '1'; 
            count = 0;
        end
    else
        count = 0;
        chiper_bit_stuffing(index) = chiper_stream(i);
    end
    index = index + 1;
end
chiper_bit_stuffing = [chiper_bit_stuffing '00000' ];
len_chiper = length(chiper_bit_stuffing);
out_oo = chiper_bit_stuffing;
%///////////////////////////////////////////// 
 
%mage readng and takng the blue color nformaton of RGB pxel
%//////////////////////////////
A = imread(image_path);
image_blue = A(:,:,3);
imgblue_copy = image_blue;
[row,col] =  size(image_blue);
image_blue = double(image_blue);
%//////////////////////////////

%checking image and chiphertext Ratio
%////////////////////////////////
Ratio = ((row * col)- 8 )/ 64 ;
%////////////////////////////////

%//////////////////////////////////////////
%//////////////////////////////////////////
series_1 = [ 2 3 2 3 3 2 3 3 2 2 ]; %jumping series
series_2 = [ 2 7 5 4 3 1 6 ];  % special series for zero cases
len_series_1 = length(series_1);
len_series_2 = length(series_2);

if len_chiper > Ratio
    warndlg('Image size is very small to hide given Text. Select a larger size image','!! Warning !!');
    return;
else  
 
    
    x=1; y=1; z=1;       %len_chiper, len_series_1,len_series_2 ntalze
    i=1; j=1;   
    while i<=row
        while j<=col            
            if chiper_bit_stuffing(x)=='1'
                if mod(image_blue(i,j),2)==0 % even ie LSB = 0                    
                    image_blue(i,j) = image_blue(i,j) + 1 ;
                end
            else
                if mod(image_blue(i,j),2)==1 % Odd ie LSB = 1                    
                    image_blue(i,j) = image_blue(i,j) - 1 ;
                end
            end
            x = x+1;
            if x > len_chiper
                break;
            end                
            
            n1 = series_1(y);
            n2 = image_blue(i,j);
            if n1 == 2
                n =floor( n2 / 64);
            else
                n = floor(n2/ 32);
            end
            
            if n == 0
                n = series_2(z);
                if z < len_series_2
                    z = z+1;
                else
                    z=1;
                end
            end
            
            
            if y < len_series_1
                y = y+1;
            else
                y=1;
            end
            
            j = j+n;           
            
        end       
      
        i = i + 1;
        j = n;
        if x > len_chiper
                break;
        end
        
    end
end

figure,subplot(1,2,1),imshow(A), xlabel( 'Cover Image.bmp');
A(:,:,3) = image_blue; 
subplot(1,2,2),imshow(A), xlabel( 'Stego Image.bmp');
msgbox('Data hidding is done, Stego Image is ready to save. Save stego image in .bmp or .tiff','!! Success!!');


% GETtng the absolute path to save the stego mage
%////////////////////////////////////////////////
ext = '';
while ~strcmp(ext,'tiff') && ~strcmp(ext,'tif')&& ~strcmp(ext,'bmp')
    [path, ext, user_canceled] = imputfile;
    if user_canceled == 1
        break;
    end
end

if strcmp(ext,'tiff') || strcmp(ext,'tif')|| strcmp(ext,'bmp')
    imwrite(A,path);
else
    warndlg('Stego image is not saved','!! Warning !!');
end





