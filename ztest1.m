% key = [1 2 3 4 5 6 7 8 9 6 5 4 1 2 3 5];
%plaintext = [105 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 ];
clc
clear all
k1 = 'dhfahuejfj';
len = length(k1)
if len< 16
    for i=len+1 : 1:16
        k1 = [k1 '*']
    end
end
key = double(k1);
len = length(k1)
% modulas use kore 16 er multiple kina check korbo
plain1 = 'lBCD            '
plaintext  = double(plain1)
%plaintext = [105 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 ];
%  s = aesinit(key);
% chipertext = aes(s,'encrypt','ecb', plaintext);
%  disp(chipertext);
%  disp(char(chipertext));
% % %dec2bin(chipertext)
%  outtext = aes(s,'decrypt','ecb', chipertext);
%  disp(outtext)
