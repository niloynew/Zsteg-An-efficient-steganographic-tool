clc
clear all
% a = 10;
% i=1; j=1
% while  i<= 10
%    
%    while  j<= 6
%         i
%        j
%        k=i
%        j =  j +1;
%        if j==5
%            break;
%        end
%    
%    end
%    i = i+1;
%    j = k;
%    
% end

% A = imread('img\test2.bmp');
% b=A(:,:,3);
% b(1,2)=35;
% b(3,5)=254;
% A(:,:,3)=b;
% imwrite(A,'stegotest1.bmp');
% f = imread('stegotest1.bmp');


% A = imread('img\test2.bmp');
% b=A(:,:,3);
% b(1,2)=35;
% b(3,5)=254;
% A(:,:,3)=b;
% imwrite(A,'stegotest2.jpg');
% f = imread('stegotest2.jpg');
% figure,subplot(1,2,1),imshow(A);
% subplot(1,2,2),imshow(f);

key = '1234************';
out = '10000101000001101011001100100101101001011011001110100111000010000100110100111101101101010101010000110011010101010100110011110100';
out_len = length(out);
out_bit_stuffing = char.empty(0,1000);
count =0;
index=1;
%To provide EOF= '00000' using bit stuffing inserting 1 after 4 zeros
for i=1: out_len
    if out(i)== '0'
        count = count + 1;
        out_bit_stuffing(index) = out(i);
        if count == 4
            index = index + 1;
            out_bit_stuffing(index) = '1';            
        end
    else
        count = 0;
        out_bit_stuffing(index) = out(i);
    end
    index = index + 1;
end
out_bit_stuffing = [out_bit_stuffing '00000' ];
out_oo = out_bit_stuffing;



% %To provide EOF= '00000' using bit stuffing deleting 1 after 4 zeros
flag = 0;
i=1;
jk=1;
out_now = char.empty(0,100);
count = 0;
while i>0
    if out_bit_stuffing(i) == '0'
        count = count + 1;
        out_now(jk)= '0';
        if count == 4 && out_bit_stuffing(i+1) == '1'
            flag =1;
        end
        if count == 5
            break;
        end
    else
        count = 0;  
        out_now(jk)= '1';
    end
    
    if flag == 1        
        flag = 0;
        i = i+1;
        count = 0;
    end
    i = i+1;
    jk = jk +1;
end




out1 = reshape(out, 8, [])';
out2 = bin2dec(out1);
out3 = char(out2);
out4 = out3';


 outtext = double(out4);
 key = double(key);
 s = aesinit(key);
 sms = aes(s,'decrypt','ecb', outtext);
 disp(sms)
 disp(char(sms));







