function out = DecimateMultiple( data, decimationFactor )

out = [];

for ii=1:size(data, 2)
    out = [out, decimate(data(:,ii), decimationFactor)];
end

