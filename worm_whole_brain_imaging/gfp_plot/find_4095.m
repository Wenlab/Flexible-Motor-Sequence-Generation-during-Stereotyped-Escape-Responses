k=0;
for frame = 1:length(img_stack)
    now_frame = 0;
    [height,width] = size(img_stack{frame,1});
    for i = 1:height
        for j= 1:width
            if (img_stack{frame,1}(i,j)==4095  && frame ~= now_frame)
                disp(frame)
                k=k+1;
                B(k,1)=frame;
                now_frame = frame;
            end
        end
    end
end
                
                
                