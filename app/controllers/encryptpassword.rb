require 'date'
require 'stringio'
require 'base64'
require 'openssl'
require 'cgi'

class Encryptpassword
  VECTOR = "sgs2013ec2%lumba"
  def encode(text)
        k = 16
        l = text.length
        output = StringIO.new
        val = k - (l % k)
        val.times { output.write('%02x' % val)  }
    return text.to_s + output.string.hex_to_binary
  end

  def getEncryptedPassword(password)
    raw = "Key=zesagape7u2a7apedazu3u7u3a9a4ed&GenDT=#{password}"
    pad_text = encode(raw)
    encryptor = OpenSSL::Cipher.new("AES-256-CBC")
    encryptor.iv = VECTOR.encode("ascii")
    encryptor.encrypt
    encryptor.key = "zesagape7u2a7apedazu3u7u3a9a4eda"
    abc = encryptor.update(pad_text)
    result = CGI.escape(Base64.encode64(abc))
    result_final = result.gsub("%0A", "")
puts "result_final " + result_final
    result_final
  end
end

class String
  def hex_to_binary
    temp = gsub("\s", "");
    ret = []
    (0...temp.size()/2).each{|index| ret[index] = [temp[index*2, 2]].pack("H2")}
 abc = ret[0] + ret[1]
    return abc
  end
end
