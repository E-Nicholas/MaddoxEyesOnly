function epoch = BMEbaseline(epoch,tvec,trange)
% BME baseline does a baseline subtraction of the epoched data contained in
% epoch, the output of BMEepoch. BMEbaseline also takes tvec output of
% BMEepoch and wants a trange over which to compute a mean to subtract
% given in the same units provided to BMEepoch
    [val, startidx] = min(abs(tvec-trange(1)));
    [val, endidx] = min(abs(tvec-trange(2)));
    
    temp = zeros(size(epoch));
    for i = 1:size(epoch,2)
        for j = 1:size(epoch,3)
            temp(:,i,j) = epoch(:,i,j)-mean(epoch(startidx:endidx,i,j));
        end
    end
    epoch = temp;

end