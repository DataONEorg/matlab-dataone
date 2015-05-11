function y = textreadFile(fname)
    y = textread(fname, '%s', 'bufsize',100000095,'whitespace', '')
end