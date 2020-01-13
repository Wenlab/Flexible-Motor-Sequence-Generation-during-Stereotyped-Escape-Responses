[ImgLength,~]=size(calcium_signal);
for i=1:ImgLength
    if ~isempty(calcium_signal{i,1})
        x1=floor(neuron_position_data{i,1}(1,1));
        y1=floor(neuron_position_data{i,1}(2,1));
        x2=floor(neuron_position_data{i,1}(1,2));
        y2=floor(neuron_position_data{i,1}(2,2));
        calcium_signal_normalized{i,1}(1,1)=calcium_signal{i,1}(1,1)/Mask(x1,y1);
        calcium_signal_normalized{i,1}(2,1)=calcium_signal{i,1}(2,1)/Mask(x2,y2);
    else
        calcium_signal_normalized{i,1}=[];
    end
end

