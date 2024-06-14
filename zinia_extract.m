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

%inputs stego image, password
%/////////////////////////////////////
[ filename,filepath ] = uigetfile({'*.bmp';'*.tiff';'*.tif'},'Select Stego Image');
image_path = [filepath filename];
title = 'ZSteg';
inputs={ 'Password' };
defaultans = {'****************'};
getinputs = inputdlg(inputs,title,[ 1 50],defaultans);
%//////////////////////////////////////

%Setting key as multiple of 16
%//////////////////////////////
key = getinputs{1};
len_key = length(key);
key_extra = mod(len_key, 16);
key_add = 16 - key_extra;
add = char.empty(0,15);
for i=1 : 1:key_add
    add(i) =  '*';
end
key = [key add];
%///////////////////////


A = imread(image_path);
image_blue = A(:,:,3);
[row,col] =  size(image_blue);
image_blue = double(image_blue);


series_1 = [ 2 3 2 3 3 2 3 3 2 2 ]; %jumpng seres
series_2 = [ 2 7 5 4 3 1 6 ];  % specal seres for zero cases
len_series_1 = length(series_1);
len_series_2 = length(series_2);

% Extractng the lsb of the pixels
%///////////////////////////////
outtext = char.empty(0,10000);
y=1;
z=1;
i=1;
j=1;
n=1;
out_i = 1;
count = 0;
while i<=row
    
    while j<=col
        
        if mod(image_blue(i,j),2)==0 % even ie LSB = 0
            count = count + 1;
            outtext(out_i) = '0';
            if count == 5
                break;
            end
            
        else % Odd ie LSB = 1
            count = 0;
            outtext(out_i) = '1';
        end
        
        out_i = out_i + 1;
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
        
        j = j + n;
      
    end
    if count == 5
        break;
    end
    i = i + 1;
    j = n;
end
%//////////////////////////////////////////////////////


%To provide EOF= '00000' using bit stuffing deleting 1 after 4 zeros
%///////////////////////////////////////////////////////
flag = 0;
i=1;
jk=1;
out_cipher = char.empty(0,10000);
count = 0;
while i>0
    if outtext(i) == '0'
        count = count + 1;
        out_cipher(jk)= '0';
        if count == 4 && outtext(i+1) == '1'
            flag =1;
        end
        if count == 5
            break;
        end
    else
        count = 0;  
        out_cipher(jk)= '1';
    end
    
    if flag == 1        
        flag = 0;
        i = i+1;
        count = 0;
    end
    i = i+1;
    jk = jk +1;
end
%////////////////////////////////////////////////////////

%Getting the actual cipher
%////////////////////////////////////////////////////////
cipher = char.empty(0,1000);
out_cipher_len = length(out_cipher);
extra_bit_no = mod(out_cipher_len,16);
for i=1:out_cipher_len-extra_bit_no
    cipher(i) = out_cipher(i);
end
%////////////////////////////////////////////////////////
%key_extra = mod(len_key, 16);
%key_add = 16 - extra_bit_no;
%add = char.empty(0,15);
%for i=1 : 1:key_add
%        add(i)= '*';
%end
%key = [key add];


%Decrypting the outtext using key
%//////////////////////////////
cipher_text = char(bin2dec(reshape(cipher, 8, [])'))';
 %Setting cipher as multiple of 16
%//////////////////////////////

len_cipher = length(cipher_text);
key_extra = mod(len_cipher, 16);
key_add = 16 - key_extra;
add = char.empty(0,15);
for i=1 : 1:key_add
        add(i)= '*';
end
cipher_text = [cipher_text add];
cipher_text = double(cipher_text);

 key = double(key);
 s = aesinit(key);
 sms_star = aes(s,'decrypt','ecb', cipher_text);
 sms_star = char(sms_star);
 %/////////////////////////////
 
 %Getting Actual Plaintext
 %////////////////////////
 plaintext = char.empty(0,15);
 for i = 1: length(sms_star)
     if sms_star(i) =='*'
         break;
     else
     plaintext(i) =sms_star(i);
     end
 end 
 %////////////////////////
 disp(plaintext);
 msgbox(plaintext,'SECRET DATA','custom',A) ;
 