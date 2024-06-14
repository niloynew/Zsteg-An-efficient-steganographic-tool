function [output] = aes(s, oper, mode, input, iv, sbit)
% AES Encrypt/decrypt array of bytes by AES.
% output = aes(s, oper, mode, input, iv, sbit)
% Encrypt/decrypt array of bytes by AES-128, AES-192, AES-256.
% All NIST SP800-38A cipher modes supported (e.g. ECB, CBC, OFB, CFB, CTR).
% Usage example:    out = aesdecrypt(s, 'dec', 'ecb', data)
% s:                AES structure (generated by aesinit)
% oper:             operation:
%                   'e', 'enc', 'encrypt', 'E',... = encrypt
%                   'd', 'dec', 'decrypt', 'D',... = decrypt
% mode:             operation mode
%                   'ecb' = Electronic Codebook Mode
%                   'cbc' = Cipher Block Chaining Mode
%                   'cfb' = Cipher Feedback Mode
%                   'ofb' = Output Feedback Mode
%                   'ctr' = Counter Mode
%                   For counter mode you need external AES_GET_COUNTER()
%                   counter function.
% input:            plaintext/ciphertext byte-vector with length
%                   multiple of 16
% iv:               initialize vector - some modes need it
%                   ending initialize vector is stored in s.iv, so you
%                   can use aes() repetitively to encode/decode
%                   large vector:
%                   out = aes(s, 'enc', 'cbc', input1, iv);
%                   out = [out aes(s, 'enc', 'cbc', input1, s.iv)];
%                   ...
% sbit:             bit-width parameter for CFB mode
% output:           ciphertext/plaintext byte-vector
%
% See
% Morris Dworkin, Recommendation for Block Cipher Modes of Operation
% Methods and Techniques
% NIST Special Publication 800-38A, 2001 Edition
% for details.

% Stepan Matejka, 2011, matejka[at]feld.cvut.cz
% $Revision: 1.1.0 $  $Date: 2011/10/12 $

%error(nargchk(4, 6, nargin));

validateattributes(s, {'struct'}, {});
validateattributes(oper, {'char'}, {});
validateattributes(mode, {'char'}, {});
validateattributes(input, {'numeric'}, {'real', 'vector', '>=', 0, '<', 256});
if (nargin >= 5)
    validateattributes(iv, {'numeric'}, {'real', 'vector', '>=', 0, '<', 256});
    if (length(iv) ~= 16)
        error('Length of ''iv'' must be 16.');
    end
end
if (nargin >= 6)
    validateattributes(sbit, {'numeric'}, {'real', 'scalar', '>=', 1, '<=', 128});
end

if (mod(length(input), 16))
    error('Length of ''input'' must be multiple of 16.');
end

switch lower(oper)
    case {'encrypt', 'enc', 'e'}
        oper = 0;
    case {'decrypt', 'dec', 'd'}
        oper = 1;
    otherwise
        error('Bad ''oper'' parameter.');
end

blocks = length(input)/16;
input = input(:);

switch lower(mode)

    case {'ecb'}
        % Electronic Codebook Mode
        % ------------------------
        output = zeros(1,length(input));
        idx = 1:16;
        for i = 1:blocks
            if (oper)
                % decrypt
                output(idx) = aesdecrypt(s,input(idx));
            else
                % encrypt
                output(idx) = aesencrypt(s,input(idx));
            end
            idx = idx + 16;
        end
        
    case {'cbc'}
        % Cipher Block Chaining Mode
        % --------------------------
        if (nargin < 5)
            error('Missing initialization vector ''iv''.');
        end
        output = zeros(1,length(input));
        ob = iv;
        idx = 1:16;
        for i = 1:blocks
            if (oper)
                % decrypt
                in = input(idx);
                output(idx) = bitxor(ob(:), aesdecrypt(s,in)');
                ob = in;
            else
                % encrypt
                ob = bitxor(ob(:), input(idx));
                ob = aesencrypt(s, ob);
                output(idx) = ob;
            end
            idx = idx + 16;
        end
        % store iv for block passing
        s.iv = ob;
        
    case {'cfb'}
        % Cipher Feedback Mode
        % --------------------
        % Special mode with bit manipulations
        % sbit = 1..128
        if (nargin < 6)
            error('Missing ''sbit'' parameter.');
        end
        % get number of bits
        bitlen = 8*length(input);
        % loop counter
        rounds = round(bitlen/sbit);
        % check 
        if (rem(bitlen, sbit))
            error('Message length in bits is not multiple of ''sbit''.');
        end
        % convert input to bitstream
        inputb = reshape(de2bi(input,8,2,'left-msb')',1,bitlen);
        % preset init. vector
        ib = iv;
        ibb = reshape(de2bi(ib,8,2,'left-msb')',1,128);
        % preset output binary stream
        outputb = zeros(size(inputb));
        for i = 1:rounds
            iba = aesencrypt(s, ib);
            % convert to bit, MSB first
            ibab = reshape(de2bi(iba,8,2,'left-msb')',1,128);
            % strip only sbit MSB bits
            % this goes to xor
            ibab = ibab(1:sbit);
            % strip bits from input
            inpb = inputb((i - 1)*sbit + (1:sbit));
            % make xor
            outb = bitxor(ibab, inpb);
            % write to output
            outputb((i - 1)*sbit + (1:sbit)) = outb;
            if (oper)
                % decrypt
                % prepare new iv - bit shift
                ibb = [ibb((1 + sbit):end) inpb];
            else
                % encrypt
                % prepare new iv - bit shift
                ibb = [ibb((1 + sbit):end) outb];
            end
            % back to byte ary
            ib = bi2de(vec2mat(ibb,8),'left-msb');
            % loop
        end
        output = bi2de(vec2mat(outputb,8),'left-msb');
        % store iv for block passing
        s.iv = ib;
        
    case {'ofb'}
        % Output Feedback Mode
        % --------------------
        if (nargin < 5)
            error('Missing initialization vector ''iv''.');
        end
        output = zeros(1,length(input));
        ib = iv;
        idx = 1:16;
        for i = 1:blocks
            % encrypt, decrypt
            ib = aesencrypt(s, ib);
            output(idx) = bitxor(ib(:), input(idx));
            idx = idx + 16;
        end
        % store iv for block passing
        s.iv = ib;
        
    case {'ctr'}
        % Counter Mode
        % ------------
        if (nargin < 5)
            iv = 1;
        end
        output = zeros(1,length(input));
        idx = 1:16;
        for i = (iv):(iv + blocks - 1)
            ib = AES_GET_COUNTER(i);
            ib = aesencrypt(s, ib);
            output(idx) = bitxor(ib(:), input(idx));
            idx = idx + 16;
        end
        s.iv = iv + blocks;
        
    otherwise
        error('Bad ''oper'' parameter.');
end

% ------------------------------------------------------------------------
% end of file
