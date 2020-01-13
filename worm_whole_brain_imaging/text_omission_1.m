l=length(neuron_index_data)
for i=1:l
    if length(neuron_index_data{i})==1 & neuron_index_data{i}(1,1)==1
        %fprintf('%d\n',i);
    else
        fprintf('%d\n',i);
    end
end